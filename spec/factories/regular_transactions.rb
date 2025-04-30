FactoryBot.define do
  factory :regular_transaction do
    legal_aid_application
    transaction_type
    amount { 500.00 }
    frequency { "weekly" }

    trait :benefits do
      transaction_type { TransactionType.find_by(name: "benefits") || create(:transaction_type, :benefits) }
    end

    trait :maintenance_in do
      transaction_type { TransactionType.find_by(name: "maintenance_in") || create(:transaction_type, :maintenance_in) }
    end

    trait :maintenance_out do
      transaction_type { TransactionType.find_by(name: "maintenance_out") || create(:transaction_type, :maintenance_out) }
    end

    trait :housing_benefit do
      transaction_type { TransactionType.find_by(name: "housing_benefit") || create(:transaction_type, :housing_benefit) }
    end

    trait :rent_or_mortgage do
      transaction_type { TransactionType.find_by(name: "rent_or_mortgage") || create(:transaction_type, :rent_or_mortgage) }
    end

    trait :friends_or_family do
      transaction_type { TransactionType.find_by(name: "friends_or_family") || create(:transaction_type, :friends_or_family) }
    end

    trait :child_care do
      transaction_type { TransactionType.find_by(name: "child_care") || create(:transaction_type, :child_care) }
    end
  end
end
