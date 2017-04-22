FactoryGirl.define do
  factory :user do
    username Faker::Internet.user_name
    email Faker::Internet.free_email
    password Faker::Internet.password(8, 256)
    firstname Faker::Name.first_name
    lastname Faker::Name.last_name
    role User::ROLES.sample

    trait :confirmed do
      confirmed_at Time.now
    end
  end
end
