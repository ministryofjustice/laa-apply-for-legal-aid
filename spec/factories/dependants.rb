FactoryBot.define do
  factory :dependant do
    legal_aid_application
    number { Faker::Number.number(digits: 2) }
    name { Faker::Name.name }
    date_of_birth { Faker::Date.birthday(min_age: 7, max_age: 77) }
    relationship { Dependant.relationships.keys.sample }
    monthly_income { rand(1...10_000.0).round(2) }
    has_income { Faker::Boolean.boolean }
    in_full_time_education { Faker::Boolean.boolean }
    has_assets_more_than_threshold { Faker::Boolean.boolean }
    assets_value { rand(1...10_000.0).round(2) }

    trait :over18 do
      date_of_birth { Faker::Date.birthday(min_age: 19, max_age: 65) }
    end

    trait :under18 do
      date_of_birth { Faker::Date.birthday(min_age: 1, max_age: 17) }
    end
  end
end
