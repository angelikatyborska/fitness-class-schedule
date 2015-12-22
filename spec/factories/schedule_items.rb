FactoryGirl.define do
  factory :schedule_item do
    association :trainer
    association :room
    start { Faker::Time.between(Time.zone.now + 1.day, Time.zone.now + 15.day).beginning_of_day + Faker::Number.between(1, 70) * 15.minutes }
    duration { [45, 60, 90, 120].sample }
    capacity { Faker::Number.between(7, 20) }
    activity { ScheduleItem.activities.sample }

    factory :schedule_item_this_week do
      start { Faker::Time.between(Time.zone.now.beginning_of_week, Time.zone.now.beginning_of_week + 6.day).beginning_of_day + Faker::Number.between(1, 84) * 15.minutes }
    end

    factory :schedule_item_next_week do
      start { Faker::Time.between(Time.zone.now.beginning_of_week + 7.days, Time.zone.now.beginning_of_week + 13.day).beginning_of_day + Faker::Number.between(1, 84) * 15.minutes }
    end
  end
end
