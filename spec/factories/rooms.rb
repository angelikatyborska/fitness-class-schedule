FactoryGirl.define do
  factory :room do
    name { Faker::Lorem.word }
  end
end
