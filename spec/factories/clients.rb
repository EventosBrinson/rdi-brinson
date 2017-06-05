FactoryGirl.define do
  factory :client do
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.last_name }
    street { Faker::Address.street_name }
    inner_number { Faker::Address.building_number }
    outer_number { Faker::Address.building_number }
    neighborhood { Faker::Address.street_name }
    postal_code { Faker::Address.zip_code }
    telephone_1 { Faker::PhoneNumber.cell_phone }
    telephone_2 { Faker::PhoneNumber.cell_phone }
    email { Faker::Internet.unique.free_email }
    id_name { Client::ID_NAMES.sample }
    trust_level { (1..10).to_a.sample }
    creator { FactoryGirl.create :user }

    trait :active do
      active true
    end

    trait :inactive do
      active false
    end
  end
end
