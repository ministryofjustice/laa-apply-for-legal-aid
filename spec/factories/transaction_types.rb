# (0..10).map {|n| repeating_sequence(n, 3)} gives: [0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1]
def repeating_sequence(current, length)
  current - (length * (current / length))
end

# using repeating_sequence here so that index is always within the range of existing names
def repeating_sequence_for_transaction_type(type, current)
  names = TransactionType::NAMES[type]
  index = repeating_sequence(current, names.length)
  names[index]
end

FactoryBot.define do
  factory :transaction_type do
    name { Faker::Commerce.unique.product_name.underscore }
    operation { TransactionType::NAMES.keys.sample }

    trait :credit_with_standard_name do
      sequence(:name) do |n|
        repeating_sequence_for_transaction_type(:credit, n)
      end
      operation { 'credit' }
    end

    trait :debit_with_standard_name do
      sequence(:name) do |n|
        repeating_sequence_for_transaction_type(:debit, n)
      end
      operation { 'debit' }
    end
  end
end
