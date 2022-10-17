FactoryBot.define do
  factory :regular_transaction do
    legal_aid_application
    transaction_type
    amount { 500.00 }
    frequency { "weekly" }

    trait :benefits do
      association :transaction_type, :benefits
    end

    trait :maintenance_in do
      association :transaction_type, :maintenance_in
    end

    trait :maintenance_out do
      association :transaction_type, :maintenance_out
    end

    trait :housing_benefit do
      transaction_type { TransactionType.where(name: "housing_benefit").first || create(:transaction_type, :housing_benefit) }
    end

    trait :rent_or_mortgage do
      transaction_type { TransactionType.where(name: "rent_or_mortgage").first || create(:transaction_type, :rent_or_mortgage) }
    end
  end
end
