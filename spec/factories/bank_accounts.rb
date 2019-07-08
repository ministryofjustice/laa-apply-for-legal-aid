FactoryBot.define do
  factory :bank_account do
    bank_provider
    true_layer_id { SecureRandom.hex }
    name { Faker::Bank.name }
    currency { Faker::Currency.code }
    account_number { Faker::Number.number(10) }
    sort_code { Faker::Number.number(6) }
    balance { rand(1...1_000_000.0).round(2) }
  end
end
