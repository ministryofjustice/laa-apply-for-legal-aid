FactoryBot.define do
  factory :bank_account do
    bank_provider
    true_layer_id { SecureRandom.hex }
    name { Faker::Bank.name }
    currency { Faker::Currency.code }
    account_number { Faker::Number.number }
    sort_code { Faker::Number.number(digits: 6) }
    balance { BigDecimal(rand(1...1_000_000.0), 2) }
    account_type { %w[TRANSACTION SAVINGS].sample }
  end
end
