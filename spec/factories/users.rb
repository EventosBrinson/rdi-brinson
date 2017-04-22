FactoryGirl.define do
  factory :user do
    username Faker::Internet.user_name
    email Faker::Internet.free_email
    firstname Faker::Name.first_name
    lastname Faker::Name.last_name
    role User::ROLES.sample

    trait :confirmation_open do
      after(:create) do |user, evaluator|
        Users::OpenConfirmation.for user: user
      end
    end

    trait :confirmed do
      password Faker::Internet.password(8, 256)
      confirmed_at Time.now
    end
  end
end
