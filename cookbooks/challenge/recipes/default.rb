user_home = "/home/" + node["user"]
rails_app_path = "/opt/challenge"

remote_directory rails_app_path do
  source "rails_messaging_app"
  owner node["user"]
  group node["user"]
  mode 0755
end

ruby_block "setup-environment" do
  block do
    ENV['RUBY_VERSION'] = File.read("#{rails_app_path}/.rbenv-version")
    ENV['RUBY_PATH'] = user_home + "/local/" + ENV['RUBY_VERSION']
    ENV['RUBY_BIN_PATH'] = ENV['RUBY_PATH'] + '/bin'
    ENV['RAILS_ENV'] = "production"
    ENV['PATH'] = ENV['RUBY_BIN_PATH'] + ":" + ENV['PATH']
  end
end

# Install make and compiler required by passenger-install
package "build-essential" do
  action :install
end

bash "setup-ruby" do
  user node['user']
  cwd rails_app_path
  code <<-EOF
    ruby-build $RUBY_VERSION $RUBY_PATH
    echo "export PATH=\"$RUBY_BIN_PATH:\\$PATH\"" >> #{user_home}/.bashrc
    gem install bundler --no-rdoc --no-ri
    gem install passenger -v #{node['passenger-version']} --no-rdoc --no-ri
  EOF
end

package "libxml2-dev" do
  action :install
end

package "libxslt1-dev" do
  action :install
end

bash "setup-challenge" do
  user node['user']
  cwd rails_app_path
  code <<-EOH
    bundle install --deployment --without development test
    bundle exec rake db:create
    bundle exec rake db:schema:load
    bundle exec rake db:seed
    bundle exec rake assets:precompile
    rm -f db/seeds.rb
  EOH
end

# Required for passenger-install-nginx-module
package "libcurl4-openssl-dev" do
  action :install
end

bash "passenger-install-nginx-module" do
  user "root"
  cwd user_home
  code <<-EOH
    passenger-install-nginx-module --auto --auto-download --prefix=/opt/nginx
  EOH
end

ruby_block "create /opt/nginx/conf/nginx.conf from template" do
  block do
    res = Chef::Resource::Template.new "/opt/nginx/conf/nginx.conf", run_context
    res.source "nginx.conf.erb"
    res.cookbook cookbook_name.to_s
    res.variables(
      passenger_root: "#{ENV["RUBY_PATH"]}/lib/ruby/gems/1.9.1/gems/passenger-#{node['passenger-version']}",
      passenger_ruby: "#{ENV["RUBY_PATH"]}/bin/ruby",
      root: "/opt/challenge/public"
    )
    res.run_action :create
  end
end

cookbook_file "/etc/init.d/nginx" do
  source "init_d_script"
  mode 0755
end

ruby_block "set-database-read-only" do
  block do
    file = Chef::Util::FileEdit.new("/etc/postgresql/#{node['pgsql-version']}/main/postgresql.conf")
    file.insert_line_if_no_match("/default_transaction_read_only = on/", "default_transaction_read_only = on")
    file.write_file
  end
end

# Delete postgres command so users cannot run it when exploiting
file "/usr/bin/psql" do
  action :delete
end

service "postgresql" do
  supports :start => true, :stop => true, :restart => true
  action :restart
end

service "nginx" do
  supports :start => true, :stop => true, :restart => true
  action [:enable, :start]
end