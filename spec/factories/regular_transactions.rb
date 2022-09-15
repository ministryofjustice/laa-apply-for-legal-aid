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
  end
end
