FactoryBot.define do
  factory :dependant do
    legal_aid_application
    number { Faker::Number.number(2) }
    name { Faker::Name.name }
    date_of_birth { Faker::Date.birthday(7, 77) }
    relationship { Dependant.relationships.keys.sample }
    monthly_income { rand(1...10_000.0).round(2) }
    has_income { Faker::Boolean.boolean }
    in_full_time_education { Faker::Boolean.boolean }
    has_assets_more_than_threshold { Faker::Boolean.boolean }
    assets_value { rand(1...10_000.0).round(2) }

    trait :over_18 do
      date_of_birth { Faker::Date.birthday(19, 65) }
    end

    trait :under_18 do
      date_of_birth { Faker::Date.birthday(1, 17) }
    end
  end
end
