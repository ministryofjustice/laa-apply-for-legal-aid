FactoryBot.define do
  factory :bank_transaction do
    bank_account
    true_layer_id { SecureRandom.hex }
    description { Faker::Lorem.sentence }
    merchant { Faker::Lorem.sentence }
    happened_at { Faker::Date.backward(90) }
    currency { Faker::Currency.code }
    amount { Faker::Number.decimal(2) }

    trait :debit do
      operation { :debit }
    end
    trait :credit do
      operation { :credit }
    end
  end
end
