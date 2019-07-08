FactoryBot.define do
  factory :bank_transaction do
    bank_account
    true_layer_id { SecureRandom.hex }
    description { Faker::Lorem.sentence }
    merchant { Faker::Lorem.sentence }
    happened_at { Faker::Date.between(3.months.ago + 2.days, Time.now - 2.days) }
    currency { Faker::Currency.code }
    amount { rand(1...1_000_000.0).round(2) }

    trait :debit do
      operation { :debit }
    end
    trait :credit do
      operation { :credit }
    end
  end
end
