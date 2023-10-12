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
    name { "pension" }
    operation { "credit" }

    trait :debit do
      name { "maintenance_out" }
      operation { "debit" }
    end

    trait :credit do
      name { "maintenance_in" }
      operation { "credit" }
    end

    trait :credit_with_standard_name do
      sequence(:name) do |n|
        repeating_sequence_for_transaction_type(:credit, n)
      end
      operation { :credit }

      after(:create) do |record|
        if record.disregarded_benefit?
          parent = TransactionType.find_or_create_by!(name: "benefits", operation: "credit")
          record.update!(parent_id: parent.id)
        end
      end
    end

    trait :debit_with_standard_name do
      sequence(:name) do |n|
        repeating_sequence_for_transaction_type(:debit, n)
      end
      operation { :debit }
    end

    trait :friends_or_family do
      name { "friends_or_family" }
      operation { "credit" }
      sort_order { 20 }
    end

    trait :maintenance_in do
      name { "maintenance_in" }
      operation { "credit" }
      sort_order { 50 }
    end

    trait :property_or_lodger do
      name { "property_or_lodger" }
      operation { "credit" }
      sort_order { 50 }
    end

    trait :pension do
      name { "pension" }
      operation { "credit" }
      sort_order { 50 }
    end

    trait :benefits do
      name { "benefits" }
      operation { "credit" }
      sort_order { 30 }
    end

    trait :excluded_benefits do
      name { "excluded_benefits" }
      operation { "credit" }
      sort_order { 40 }
      parent_id { "fake-benefits-uuid" }
    end

    trait :housing_benefit do
      name { "housing_benefit" }
      operation { "credit" }
      sort_order { 50 }
      parent_id { "fake-benefits-uuid" }
    end

    trait :rent_or_mortgage do
      name { "rent_or_mortgage" }
      operation { "debit" }
      sort_order { 140 }
    end

    trait :maintenance_out do
      name { "maintenance_out" }
      operation { "debit" }
      sort_order { 160 }
    end

    trait :child_care do
      name { "child_care" }
      operation { "debit" }
      sort_order { 180 }
    end

    trait :legal_aid do
      name { "legal_aid" }
      operation { "debit" }
      sort_order { 180 }
    end

    trait :state_benefits do
      name { "state_benefits" }
      operation { "credit" }
      sort_order { 190 }
    end
  end
end
