FactoryGirl.define do
  factory :fitness_class do
    sequence(:name) { |n| ('AAAA'...'ZZZZ').to_a[n] }
    description { Faker::Lorem.paragraph(3) }
    color { Faker::Color.hex_color }
  end
end