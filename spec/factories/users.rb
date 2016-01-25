FactoryGirl.define do
  factory :user do
    sequence(:first_name) { |n| "John#{ n }" }
    sequence(:last_name) { |n| "Doe#{ n }" }
    sequence(:email) { |n| "user#{ n }@example.com" }
    password { Faker::Internet.password(8, 16) }
    confirmed_at { Time.zone.now }

    factory :admin_user do
      after :create do |user, evaluator|
        user.add_role :admin
      end
    end
  end
end
