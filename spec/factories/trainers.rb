FactoryGirl.define do
  factory :trainer do
    first_name { Faker::Name.first_name }
    description { Faker::Lorem.paragraph(3) }
  end
end