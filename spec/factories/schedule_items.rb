FactoryGirl.define do
  random_start = -> (from, to) do
    ScheduleItem.beginning_of_day(Faker::Time.between(from, to)) + (Faker::Number.between(1, ScheduleItem.day_duration_in_quarters - 4) * 15).minutes
  end

  factory :schedule_item do
    association :trainer
    association :room
    start { random_start.call(Time.zone.now + 1.day, Time.zone.now + 13.days) }
    duration { [45, 60, 90, 120].sample }
    capacity { Faker::Number.between(7, 20) }
    activity { ScheduleItem.activities.sample }

    factory :schedule_item_this_week do
      start { random_start.call(Time.zone.now.beginning_of_week, Time.zone.now.beginning_of_week + 6.days) }
    end

    factory :schedule_item_next_week do
      start { random_start.call(Time.zone.now.beginning_of_week + 7.days, Time.zone.now.beginning_of_week + 13.days) }
    end
  end
end
