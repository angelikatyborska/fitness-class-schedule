FactoryGirl.define do
  factory :reservation do
    association :user
    association :schedule_item

    after(:create) do |reservation, evaluator|
      evaluator.user.reload
      evaluator.schedule_item.reload
    end
  end
end
