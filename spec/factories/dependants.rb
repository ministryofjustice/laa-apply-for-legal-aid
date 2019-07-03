FactoryBot.define do
  factory :dependant do
    legal_aid_application
    number { Faker::Number.number(2) }
    name { Faker::Name.name }
    date_of_birth { Faker::Date.birthday(7, 77) }
  end
end
