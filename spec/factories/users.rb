FactoryGirl.define do
  factory :user do
    username Faker::Internet.user_name
    email Faker::Internet.free_email
    firstname Faker::Name.first_name
    lastname Faker::Name.last_name
    role User::ROLES.sample

    trait :confirmation_open do
      after(:create) do |user, evaluator|
        user.update confirmation_token: Utils::GenerateToken.for(data: { user_id: user.id, created_at: 1.second.ago.to_i }),
                    confirmation_sent_at: 1.second.ago
      end
    end

    trait :confirmed do
      password Faker::Internet.password(8, 256)
      confirmed_at Time.now
    end
  end
end
