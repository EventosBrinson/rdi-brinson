FactoryGirl.define do
  factory :rent do
    delivery_time { 1.hour.from_now }
    pick_up_time { 10.hours.from_now }
    product { Faker::Beer.name }
    price { Faker::Number.positive }
    discount { Faker::Number.positive }
    rent_type { Client::RENT_TYPES.sample }
    status { Rent::STATUSES.sample }
    client
    place

    after :build do |rent|
      rent.creator = rent.client.creator
    end

    trait :with_additional_charges do
      additional_charges { Faker::Number.positive }
      additional_charges_notes { Faker::ChuckNorris.fact }
    end

    trait :reserved do
      status { Rent::STATUSES[0] }
    end

    trait :on_route do
      status { Rent::STATUSES[1] }
    end

    trait :delivered do
      status { Rent::STATUSES[2] }
    end

    trait :on_pick_up do
      status { Rent::STATUSES[3] }
    end

    trait :pending do
      status { Rent::STATUSES[4] }
    end

    trait :finalized do
      status { Rent::STATUSES[5] }
    end
  end
end
