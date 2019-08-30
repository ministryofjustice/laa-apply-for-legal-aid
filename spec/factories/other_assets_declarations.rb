FactoryBot.define do
  factory :other_assets_declaration do
    legal_aid_application

    trait :with_second_home do
      second_home_value { rand(1...1_000_000.0).round(2) }
      second_home_mortgage { rand(1...1_000_000.0).round(2) }
      second_home_percentage { rand(1...99.0).round(2) }
    end

    trait :with_all_values do
      second_home_value { rand(1...1_000_000.0).round(2) }
      second_home_mortgage { rand(1...1_000_000.0).round(2) }
      second_home_percentage { rand(1...99.0).round(2) }
      timeshare_property_value { rand(1...1_000_000.0).round(2) }
      land_value { rand(1...1_000_000.0).round(2) }
      valuable_items_value { rand(1...1_000_000.0).round(2) }
      inherited_assets_value { rand(1...1_000_000.0).round(2) }
      money_owed_value { rand(1...1_000_000.0).round(2) }
      trust_value { rand(1...1_000_000.0).round(2) }
    end

    trait :all_nil do
      second_home_value { nil }
      second_home_mortgage { nil }
      second_home_percentage { nil }
      timeshare_property_value { nil }
      land_value { nil }
      valuable_items_value { nil }
      inherited_assets_value { nil }
      money_owed_value { nil }
      trust_value { nil }
    end

    trait :all_zero do
      second_home_value { 0.0 }
      second_home_mortgage { 0.0 }
      second_home_percentage { 0.0 }
      timeshare_property_value { 0.0 }
      land_value { 0.0 }
      valuable_items_value { 0.0 }
      inherited_assets_value { 0.0 }
      money_owed_value { 0.0 }
      trust_value { 0.0 }
    end

    trait :mix_of_values do
      second_home_value { rand(1...1_000_000.0).round(2) }
      second_home_mortgage { rand(1...1_000_000.0).round(2) }
      second_home_percentage { rand(1...99.0).round(2) }
      timeshare_property_value { rand(1...1_000_000.0).round(2) }
      land_value { nil }
      valuable_items_value { 0.0 }
      inherited_assets_value { 0.0 }
      money_owed_value { nil }
      trust_value { 0.0 }
    end
  end
end
