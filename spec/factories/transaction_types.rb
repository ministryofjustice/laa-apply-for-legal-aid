FactoryBot.define do
  factory :transaction_type do
    name { Faker::Commerce.unique.product_name.underscore }
    operation { TransactionType::NAMES.keys.sample }

    trait :credit_with_standard_name do
      sequence(:name) { |n| TransactionType::NAMES[:credit][n.to_i - 1] }
      operation { 'credit' }
    end

    trait :debit_with_standard_name do
      sequence(:name) { |n| TransactionType::NAMES[:debit][n.to_i - 1] }
      operation { 'debit' }
    end
  end
end
