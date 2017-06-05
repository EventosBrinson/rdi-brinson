FactoryGirl.define do
  factory :place do
    name { Faker::StarWars.planet }
    street { Faker::Address.street_name }
    inner_number { Faker::Address.building_number }
    outer_number { Faker::Address.building_number }
    neighborhood { Faker::Address.street_name }
    postal_code { Faker::Address.zip_code }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    client

    trait :active do
      active true
    end

    trait :inactive do
      active false
    end
  end
end
