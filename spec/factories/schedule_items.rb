FactoryGirl.define do
  random_start_during_week = -> (from) do
    days = rand 0..6
    minutes = 15 * (rand 0..(ScheduleItem.day_duration_in_quarters - 10))
    ScheduleItem.beginning_of_day(from) + days.days + minutes.minutes
  end

  factory :schedule_item do
    association :trainer
    association :room
    association :fitness_class
    start { random_start_during_week.call(Time.zone.now + 1.day) }
    duration { [45, 60, 90, 120].sample }
    capacity { Faker::Number.between(7, 20) }

    factory :schedule_item_this_week do
      start { random_start_during_week.call(Time.zone.now.beginning_of_week) }
    end

    factory :schedule_item_next_week do
      start { random_start_during_week.call(Time.zone.now.beginning_of_week + 7.days) }
    end

    factory :schedule_item_this_week_in_website_time_zone do
      start { random_start_during_week.call(Time.zone.now.in_website_time_zone.beginning_of_week) }
    end

    factory :schedule_item_next_week_in_website_time_zone do
      start { random_start_during_week.call(Time.zone.now.in_website_time_zone.beginning_of_week + 7.days) }
    end

    factory :full_schedule_item do
      capacity { 1 }

      after(:create) do |schedule_item, evaluator|
        create(:reservation, schedule_item: schedule_item)
      end
    end

    after(:create) do |schedule_item, evaluator|
      evaluator.room.reload
      evaluator.trainer.reload
    end
  end
end
