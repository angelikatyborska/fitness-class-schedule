# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
puts "Seeds: start"

Trainer.destroy_all
Room.destroy_all
ScheduleItem.destroy_all

6.times do
  Trainer.create!(
    first_name: Faker::Name.first_name,
    description: Faker::Lorem.paragraph(3)
  )
end

3.times do
  Room.create!(
    name: Faker::Lorem.word
  )
end

start_from = Time.zone.now + 1.day
start_to = Time.zone.now + 14.day
max_quarters = ScheduleItem.day_duration_in_quarters - 1

30.times do
  ScheduleItem.create!(
    start: ScheduleItem.beginning_of_day(Faker::Date.between(start_from, start_to)) + (Faker::Number.between(0, max_quarters).to_i * 15).minutes,
    duration: 45,
    activity: ScheduleItem.activities.sample,
    trainer: Trainer.all.sample,
    room: Room.all.sample,
    capacity: Faker::Number.between(5, 15)
  )
end

puts "Seeds: done"
