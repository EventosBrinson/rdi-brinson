FactoryGirl.define do
  factory :place do
    name { Faker::StarWars.planet }
    address_line_1 { Faker::Address.street_name + ' #' + Faker::Address.building_number }
    address_line_2 { Faker::Address.city + ', CP ' + Faker::Address.zip_code }
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
