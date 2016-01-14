FactoryGirl.define do
  factory :room do
    sequence(:name) { |n| "Room#{ n }" }
    description { Faker::Lorem.paragraph(3) }
  end
end
