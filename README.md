# Fitness Class Schedule
A Ruby on Rails app for managing fitness class reservations.

## Check it out
[fitness-class-schedule.herokuapp.com](https://fitness-class-schedule.herokuapp.com/)

###Log in credentials
Every user has the password `password`. For the administrator user, use email `admin@example.com`. For any of the regular users, use email `userX@example.com`, where X is an integer between 0 and 9. If you decide to check out registrations using a valid email, please be advised that this application sends emails to users with reservations when their class gets cancelled or edited, so you might receive some spam. The database will be reseeded from time to time, so feel free to play around.

## Dependencies
- Postgres 9.4.5,
- ImageMagick 6.9.3,
- Bower 1.7.2,
- PhantomJS 2.0.0

### Setup
If you want to run this app on your machine, you need to install all the dependencies and then:

1. `cp config/database.yml.sample config/database.yml`
2. `rake db:setup`