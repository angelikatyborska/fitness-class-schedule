FactoryGirl.define do
  factory :reservation do
    association :user
    association :schedule_item

    factory :queued_reservation do
      association :schedule_item, factory: :full_schedule_item
    end

    after :create do |reservation, evaluator|
      evaluator.user.reload
      evaluator.schedule_item.reload
    end
  end
end
