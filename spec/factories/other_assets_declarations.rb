FactoryBot.define do
  factory :other_assets_declaration do
    legal_aid_application

    trait :with_second_home do
      second_home_value { Faker::Number.decimal(6, 2) }
      second_home_mortgage { Faker::Number.decimal(6, 2) }
      second_home_percentage { Faker::Number.decimal(2, 2) }
    end

    trait :with_all_values do
      second_home_value { Faker::Number.decimal(6, 2) }
      second_home_mortgage { Faker::Number.decimal(6, 2) }
      second_home_percentage { Faker::Number.decimal(2, 2) }
      timeshare_value { Faker::Number.decimal(6, 2) }
      land_value { Faker::Number.decimal(6, 2) }
      jewellery_value { Faker::Number.decimal(6, 2) }
      vehicle_value { Faker::Number.decimal(6, 2) }
      classic_car_value { Faker::Number.decimal(6, 2) }
      money_assets_value { Faker::Number.decimal(6, 2) }
      money_owed_value { Faker::Number.decimal(6, 2) }
      trust_value { Faker::Number.decimal(6, 2) }
    end
  end
end
