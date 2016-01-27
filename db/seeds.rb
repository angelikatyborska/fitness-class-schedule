puts 'Seeds: start'
perform_deliveries_from_config = ActionMailer::Base.perform_deliveries
ActionMailer::Base.perform_deliveries = false

puts 'Cleaning the database...'

Reservation.destroy_all
ScheduleItem.destroy_all
Trainer.destroy_all
Room.destroy_all
FitnessClass.destroy_all
User.destroy_all
Configurable.destroy_all

Rails.cache.clear

puts 'Creating trainers...'

trainers = 6.times.with_object([]) do |n, trainers|
  trainers << {
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    description: Faker::Lorem.paragraph(6)
  }
end

trainers = Trainer.create!(trainers)

fitness_hall = Room.create!(
  name: 'Fitness Hall',
  description: Faker::Lorem.paragraph(3)
)

spinning_room = Room.create!(
  name: 'Spinning Room',
  description: Faker::Lorem.paragraph(3)
)

puts 'Creating rooms...'

unless Rails.env.production?
  3.times do |n|
    RoomPhoto.create!(
      room: fitness_hall,
      photo: File.open(Rails.root.join('app', 'assets', 'images', "fitness#{ n }.jpg"))
    )
  end

  3.times do |n|
    RoomPhoto.create!(
      room: spinning_room,
      photo: File.open(Rails.root.join('app', 'assets', 'images', "fitness#{ n }.jpg"))
    )
  end
end

fitness_classes_names_and_colors = [
  { name: 'Step', color: '#ff9000'},
  { name: 'ABT', color: '#cf2580'},
  { name: 'TBC', color: '#7835a2'},
  { name: 'HIIT', color: '#71360b'},
  { name: 'Zumba', color: '#ef2222'},
  { name: 'Pilates', color: '#12ae28'}
]

spinning_classes_names_and_colors = [
  { name: 'Spinning Basic', color: '#1a84f1'},
  { name: 'Spinning Strength', color: '#2b36a1'},
]

puts 'Creating classes...'

fitness_classes =
  fitness_classes_names_and_colors.each_with_object([]) do |fitness_class, classes|
    classes << FitnessClass.create!(
      name: fitness_class[:name],
      description: Faker::Lorem.paragraph(3),
      color: fitness_class[:color]
    )
  end

spinning_classes =
  spinning_classes_names_and_colors.each_with_object([]) do |spinning_class, classes|
    classes << FitnessClass.create!(
      name: spinning_class[:name],
      description: Faker::Lorem.paragraph(3),
      color: spinning_class[:color]
    )
  end

puts 'Creating schedule items...'

beginning_of_last_week = Time.zone.now.in_website_time_zone.beginning_of_week - 1.week
available_hours = (0...(ScheduleItem.day_duration_in_hours))
now = Time.zone.now.in_website_time_zone

Timecop.travel(Time.zone.now.in_website_time_zone - 1.month)

room_classes_pairings = [
  { room: fitness_hall, classes: fitness_classes, duration: 50 },
  { room: spinning_room, classes: spinning_classes, duration: 90 }
]

fitness_schedule_items = 21.times.with_object([]) do |days, items|
  available_hours.to_a.sample(available_hours.to_a.length * 1 / 3).each do |hours|
    start = ScheduleItem.beginning_of_day(beginning_of_last_week) + days.days + hours.hours
    duration = 45
    trainer = trainers[0, (trainers.length / 2)].sample

    items << {
      start: start,
      duration: duration,
      fitness_class: fitness_classes.sample,
      trainer: trainer,
      room: fitness_hall,
      capacity: Faker::Number.between(3, 5)
    }
  end
end

available_hours = available_hours.step(1.5)

spinning_items = 21.times.with_object([]) do |days, items|
  available_hours.to_a.sample(available_hours.to_a.length * 1 / 3).each do |hours|
    start = ScheduleItem.beginning_of_day(beginning_of_last_week) + days.days + hours.hours
    duration = 75
    trainer = trainers[(trainers.length / 2), (trainers.length / 2)].sample

    items << {
      start: start,
      duration: duration,
      fitness_class: spinning_classes.sample,
      trainer: trainer,
      room: spinning_room,
      capacity: Faker::Number.between(3, 5)
    }
  end
end

ScheduleItem.create!(fitness_schedule_items + spinning_items)

puts 'Creating users...'

users = 10.times.with_object([]) do |n, users|
  users << {
    email: "user#{ n }@example.com",
    password: 'password',
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    confirmed_at: Time.zone.now
  }
end

User.create!(users)

puts 'Creating reservations...'

reservations = ScheduleItem.all.each.with_object([]) do |item, reservations|
  User.all.sample((rand 5) + 2).each do |user|
    status = if item.start < now
      (rand 5) == 0 ? 'missed' : 'attended'
    else
      'active'
    end

    reservations << { user: user, schedule_item: item, status: status }
  end
end

Reservation.create!(reservations)

admin = User.create!(email: 'admin@example.com', password: 'password', first_name: 'John', last_name: 'Doe', confirmed_at: Time.zone.now)
admin.add_role(:admin)

Timecop.return

ActionMailer::Base.perform_deliveries = perform_deliveries_from_config

puts 'Seeds: done'
