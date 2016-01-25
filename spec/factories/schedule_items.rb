FactoryGirl.define do
  factory :schedule_item do
    association :trainer
    association :room
    association :fitness_class
    start { ScheduleItem.beginning_of_day(Time.zone.now + 1.day) }
    duration { [45, 60, 90, 120].sample }
    capacity { Faker::Number.between(7, 20) }

    factory :schedule_item_this_week do
      start { ScheduleItem.beginning_of_day(Time.zone.now.beginning_of_week) }
    end

    factory :schedule_item_next_week do
      start { ScheduleItem.beginning_of_day(Time.zone.now.beginning_of_week + 7.days) }
    end

    factory :schedule_item_this_week_in_website_time_zone do
      start { ScheduleItem.beginning_of_day(Time.zone.now.in_website_time_zone.beginning_of_week) }
    end

    factory :schedule_item_next_week_in_website_time_zone do
      start { ScheduleItem.beginning_of_day(Time.zone.now.in_website_time_zone.beginning_of_week + 7.days) }
    end

    factory :full_schedule_item do
      capacity { 1 }

      after :create do |schedule_item, evaluator|
        create :reservation, schedule_item: schedule_item
      end
    end

    after :create do |schedule_item, evaluator|
      evaluator.room.reload
      evaluator.trainer.reload
    end
  end
end
