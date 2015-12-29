FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Internet.password(8, 16) }

    factory :admin_user do
      after(:create) do |user, evaluator|
        user.add_role(:admin)
      end
    end
  end
end
