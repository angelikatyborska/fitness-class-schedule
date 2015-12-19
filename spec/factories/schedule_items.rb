FactoryGirl.define do
  factory :schedule_item do
    association :trainer
    start { Faker::Time.between(DateTime.now.middle_of_day + 1.day, DateTime.now.middle_of_day + 15.day) }
    duration { [45, 60, 90, 120].sample }
    capacity { Faker::Number.between(7, 20) }
    activity { ScheduleItem.activities.sample }
  end
end