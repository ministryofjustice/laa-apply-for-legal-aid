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
      money_assets_value { Faker::Number.decimal(6, 2) }
      money_owed_value { Faker::Number.decimal(6, 2) }
      trust_value { Faker::Number.decimal(6, 2) }
    end

    trait :all_nil do
      second_home_value { nil }
      second_home_mortgage { nil }
      second_home_percentage { nil }
      timeshare_value { nil }
      land_value { nil }
      jewellery_value { nil }
      money_assets_value { nil }
      money_owed_value { nil }
      trust_value { nil }
    end

    trait :all_zero do
      second_home_value { 0.0 }
      second_home_mortgage { 0.0 }
      second_home_percentage { 0.0 }
      timeshare_value { 0.0 }
      land_value { 0.0 }
      jewellery_value { 0.0 }
      money_assets_value { 0.0 }
      money_owed_value { 0.0 }
      trust_value { 0.0 }
    end

    trait :mix_of_values do
      second_home_value { Faker::Number.decimal(6, 2) }
      second_home_mortgage { Faker::Number.decimal(6, 2) }
      second_home_percentage { Faker::Number.decimal(6, 2) }
      timeshare_value { Faker::Number.decimal(6, 2) }
      land_value { nil }
      jewellery_value { 0.0 }
      money_assets_value { 0.0 }
      money_owed_value { nil }
      trust_value { 0.0 }
    end
  end
end
