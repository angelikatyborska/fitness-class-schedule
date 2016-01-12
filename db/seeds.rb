puts "Seeds: start"

Trainer.destroy_all
Room.destroy_all
ScheduleItem.destroy_all
FitnessClass.destroy_all

6.times do
  Trainer.create!(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    description: Faker::Lorem.paragraph(3)
  )
end

fitness_hall = Room.create!(name: 'Fitness Hall')
spinning_room = Room.create!(name: 'Spinning Room')

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

beginning_of_week = Time.zone.now.beginning_of_week
available_hours = (0...(ScheduleItem.day_duration_in_hours)).to_a

Timecop.freeze(beginning_of_week)

room_classes_pairings = [
  { room: fitness_hall, classes: fitness_classes},
  { room: spinning_room, classes: spinning_classes }
]

room_classes_pairings.each_with_index do |pairing, index|
  10.times do |days|
    available_hours.sample(available_hours.length * 1 / 2).each do |hours|
      ScheduleItem.create!(
        start: ScheduleItem.beginning_of_day(beginning_of_week) + days.days + hours.hours,
        duration: 45,
        fitness_class: pairing[:classes].sample,
        trainer: Trainer.all[index * 3..(index * 3 + 1)].sample,
        room: pairing[:room],
        capacity: Faker::Number.between(5, 15)
      )
    end
  end
end

Timecop.return

puts "Seeds: done"
