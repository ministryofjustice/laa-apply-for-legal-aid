FactoryBot.define do
  factory :savings_amount do
    legal_aid_application

    trait :with_values do
      isa { Faker::Number.decimal.to_d }
      cash { Faker::Number.decimal.to_d }
      other_person_account { Faker::Number.decimal.to_d }
      national_savings { Faker::Number.decimal.to_d }
      plc_shares { Faker::Number.decimal.to_d }
      peps_unit_trusts_capital_bonds_gov_stocks { Faker::Number.decimal.to_d }
      life_assurance_endowment_policy { Faker::Number.decimal.to_d }
    end

    trait :all_nil do
      isa { nil }
      cash { nil }
      other_person_account { nil }
      national_savings { nil }
      plc_shares { nil }
      peps_unit_trusts_capital_bonds_gov_stocks { nil }
      life_assurance_endowment_policy { nil }
    end

    trait :all_zero do
      isa { 0.0 }
      cash { 0.0 }
      other_person_account { 0.0 }
      national_savings { 0.0 }
      plc_shares { 0.0 }
      peps_unit_trusts_capital_bonds_gov_stocks { 0.0 }
      life_assurance_endowment_policy { 0.0 }
    end

    trait :mix_of_values do
      isa { nil }
      cash { 0.0 }
      other_person_account { Faker::Number.decimal.to_d }
      national_savings { nil }
      plc_shares { 0.0 }
      peps_unit_trusts_capital_bonds_gov_stocks { Faker::Number.decimal.to_d }
      life_assurance_endowment_policy { 0.0 }
    end
  end
end
