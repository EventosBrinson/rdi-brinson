FactoryGirl.define do
  factory :client do
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.last_name }
    address_line_1 { Faker::Address.street_name + ' #' + Faker::Address.building_number }
    address_line_2 { Faker::Address.city + ', CP ' + Faker::Address.zip_code }
    telephone_1 { Faker::PhoneNumber.cell_phone }
    telephone_2 { Faker::PhoneNumber.cell_phone }
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
