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
  end
end
