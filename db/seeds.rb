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

tomorrow = Time.zone.now + 1.day
available_hours = (0..(ScheduleItem.day_duration_in_quarters / 4)).to_a

Room.all.each_with_index do |room, room_index|
  10.times do |days|
    available_hours.sample(available_hours.length * 2 / 3).each do |hours|
      ScheduleItem.create!(
        start: ScheduleItem.beginning_of_day(tomorrow) + days.days + hours.hours,
        duration: 45,
        activity: ScheduleItem.activities.sample,
        trainer: Trainer.all[room_index * 2..(room_index * 2 + 1)].sample,
        room: room,
        capacity: Faker::Number.between(5, 15)
      )
    end
  end
end

puts "Seeds: done"
