FactoryGirl.define do
  factory :schedule_item do
    association :trainer
    start { Faker::Time.between(Time.zone.now + 1.day, Time.zone.now + 15.day).beginning_of_day + Faker::Number.between(1, 84) * 15.minutes }
    duration { [45, 60, 90, 120].sample }
    capacity { Faker::Number.between(7, 20) }
    activity { ScheduleItem.activities.sample }
  end
end
