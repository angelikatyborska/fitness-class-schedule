FactoryGirl.define do
  factory :trainer do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    description { Faker::Lorem.paragraph(3) }
  end
end