FactoryBot.define do
  factory :cash_transaction do
    legal_aid_application
    transaction_type
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    month_number { 1 }

    trait :credit_month1 do
      transaction_date { Time.zone.today.at_beginning_of_month - 1.month }
      month_number { 1 }
    end

    trait :credit_month2 do
      transaction_date { Time.zone.today.at_beginning_of_month - 2.months }
      month_number { 2 }
    end

    trait :credit_month3 do
      transaction_date { Time.zone.today.at_beginning_of_month - 3.months }
      month_number { 3 }
    end

    trait :rent_or_mortgage do
      transaction_type { TransactionType.where(name: "rent_or_mortgage").first || create(:transaction_type, :rent_or_mortgage) }
    end

    trait :maintenance_in do
      transaction_type { TransactionType.find_by(name: "maintenance_in") || create(:transaction_type, :maintenance_in) }
    end

    trait :maintenance_out do
      transaction_type { TransactionType.find_by(name: "maintenance_out") || create(:transaction_type, :maintenance_out) }
    end

    trait :benefits do
      transaction_type { TransactionType.find_by(name: "benefits") || create(:transaction_type, :benefits) }
    end
  end
end
