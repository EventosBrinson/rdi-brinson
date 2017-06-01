require 'constants/images'

FactoryGirl.define do
  factory :document do
    title { Faker::Superhero.power }
    file Constants::Images::BASE64_2x2
    client
  end
end
