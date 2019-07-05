FactoryBot.define do
  factory :dependant do
    legal_aid_application
    number { Faker::Number.number(2) }
    name { Faker::Name.name }
    date_of_birth { Faker::Date.birthday(7, 77) }
    relationship {  Dependant.relationships.keys.sample }

    trait :over_18 do
      date_of_birth { Faker::Date.birthday(19, 65) }
    end

    trait :under_18 do
      date_of_birth { Faker::Date.birthday(1, 17) }
    end
  end
end
