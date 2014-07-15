Name: SQL Injection
Description: This challenge provides the users with a link to a page which has a login system on it and a description which states something along the lines of "We found this login page that jon was working on." It needs to mention jon because that is the admin user for the site. The user has to first gain access using Metasploit and use that to view the contents of the file config/initializers/secret_token.rb to get the secret token which encrypts the cookies. The user then has to figure out how to craft a cookie which will give them access to the system. In order to do this the they need to first figure out the structure of the token and then find out that the secret_token is checked into the repository. They will then have to find the name of the session token. Finally, they will need to inject that token into the browser. It will end up looking as follows:

Cookie name: _rails_messaging_app_session
Cookie value: { "session_id" => "9998712", "user_credentials"=>"jon", "user_credentials_id"=>{ :select=> " *,'jon' as persistence_token from Users where id=1 limit 1 -- " }}

Once they inject this information into their browser the site will then let them see the /messages folder. From there they will be able to retrieve the key.

How to Stand Up locally: Install [vagrant](http://vagrantup.com/) and then run `vagrant up` from the root of this directory. After the script finished, navigate to [localhost:8080](http://localhost:8080) in your browser.

flag: "MCA-A342B91C"