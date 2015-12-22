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

30.times do
  ScheduleItem.create!(
    start: Faker::Time.between(Time.zone.now + 1.day, Time.zone.now + 15.day).beginning_of_day + (Faker::Number.between(1, 80) * 15).minutes,
    duration: 45,
    activity: ScheduleItem.activities.sample,
    trainer: Trainer.all.sample,
    room: Room.all.sample,
    capacity: Faker::Number.between(5, 15)
  )
end

puts "Seeds: done"
