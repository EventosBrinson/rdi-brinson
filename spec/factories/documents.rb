FactoryGirl.define do
  factory :document do
    title { Faker::Superhero.power }
  end
end
