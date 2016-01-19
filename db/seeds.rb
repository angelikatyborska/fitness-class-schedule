puts "Seeds: start"

Trainer.destroy_all
Room.destroy_all
Reservation.destroy_all
ScheduleItem.destroy_all
FitnessClass.destroy_all
User.destroy_all

puts 'Creating trainers...'

6.times do
  Trainer.create!(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    description: Faker::Lorem.paragraph(3)
  )
end

fitness_hall = Room.create!(
  name: 'Fitness Hall',
  description: Faker::Lorem.paragraph(3)
)

spinning_room = Room.create!(
  name: 'Spinning Room',
  description: Faker::Lorem.paragraph(3)
)

puts 'Creating rooms...'

3.times do |n|
  RoomPhoto.create!(
    room: fitness_hall,
    photo: File.open(Rails.root.join('app', 'assets', 'images', "fitness#{ n }.jpg"))
  )
end

fitness_classes_names_and_colors = [
  { name: 'Step', color: '#ff9000'},
  { name: 'ABT', color: '#ea1186'},
  { name: 'TBC', color: '#8725bf'},
  { name: 'HIIT', color: '#161616'},
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

beginning_of_week = Time.zone.now.beginning_of_week
available_hours = (0...(ScheduleItem.day_duration_in_hours)).to_a

Timecop.travel(Time.zone.now - 1.month)

room_classes_pairings = [
  { room: fitness_hall, classes: fitness_classes},
  { room: spinning_room, classes: spinning_classes }
]

schedule_items = room_classes_pairings.each_with_index.with_object([]) do |(pairing, index), items|
  10.times do |days|
    available_hours.sample(available_hours.length * 1 / 3).each do |hours|
      items << {
        start: ScheduleItem.beginning_of_day(beginning_of_week) + days.days + hours.hours,
        duration: 45,
        fitness_class: pairing[:classes].sample,
        trainer: Trainer.all[(index * 3)...((index + 1) * 3)].sample,
        room: pairing[:room],
        capacity: Faker::Number.between(3, 5)
      }
    end
  end
end

ScheduleItem.create!(schedule_items)

puts 'Creating users...'

users = 7.times.with_object([]) do |n, users|
  users << {
    email: "user#{ n }@example.com",
    password: Faker::Internet.password(8),
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    confirmed_at: Time.zone.now
  }
end

User.create!(users)

puts 'Creating reservations...'

reservations = ScheduleItem.all.each.with_object([]) do |item, reservations|
  User.all.sample((rand 4) + 3).each do |user|
    reservations <<{ user: user, schedule_item: item }
  end
end

Reservation.create!(reservations)

admin = User.create!(email: 'admin@example.com', password: 'password', first_name: 'John', last_name: 'Doe', confirmed_at: Time.zone.now)
admin.add_role(:admin)

Timecop.return

puts "Seeds: done"
