FactoryGirl.define do
  factory :reservation do
    association :user
    association :schedule_item
  end
end
