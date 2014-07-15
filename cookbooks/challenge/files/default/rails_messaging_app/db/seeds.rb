# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

first_user = User.create(name: 'jon', email: 'j0n@j0n.com', password: '5a27dfc49029a8740cf1d1a2af118a94', password_confirmation: '5a27dfc49029a8740cf1d1a2af118a94')
Message.create(title: 'Hey there', body: 'Need to remember this: MCA-A342B91C', receiving_user: first_user, sending_user: first_user)