FactoryBot.define do
  factory :user do
    username { Faker::Internet.unique.user_name }
    email { Faker::Internet.unique.free_email }
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.last_name }
    role :user

    trait :confirmation_open do
      after(:create) do |user, evaluator|
        user.update confirmation_token: Utils::GenerateToken.for(data: { user_id: user.id, created_at: 1.second.ago.to_i }),
                    confirmation_sent_at: 1.second.ago
      end
    end

    trait :confirmed do
      password { Faker::Internet.password(8, 256) }
      confirmed_at { Time.now }
    end

    trait :reset_password_requested do
      confirmed
      after(:create) do |user, evaluator|
        user.update reset_password_token: Utils::GenerateToken.for(data: { user_id: user.id, created_at: 1.second.ago.to_i }),
                    reset_password_sent_at: 1.second.ago
      end
    end

    trait :admin do
      role :admin
    end

    trait :staff do
      role :staff
    end

    trait :main do
      main true
    end

    trait :active do
      active true
    end

    trait :inactive do
      active false
    end
  end
end
