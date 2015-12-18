FactoryGirl.define do
  factory :schedule_item do
    association :trainer
    start { Faker::Time.between(DateTime.now + 1.day, DateTime.now + 15.day) }
    duration { [45, 60, 90, 120].sample }
    capacity { Faker::Number.between(7, 20) }
    type { ScheduleItem.types.sample }
  end
end