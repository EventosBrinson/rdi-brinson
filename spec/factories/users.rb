FactoryGirl.define do
  factory :user do
    username 'omarandstuff'
    email 'omarandstuff@gmail.com'
    password '123456789'
    firstname 'David'
    lastname 'De Anda'
    role User::ROLES[0]
  end
end
