FactoryBot.define do
  factory :cash_transaction do
    legal_aid_application
    transaction_type
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }

    trait :credit_month1 do
      transaction_date { Date.today.at_beginning_of_month - 1.months }
    end

    trait :credit_month2 do
      transaction_date { Date.today.at_beginning_of_month - 2.months }
    end

    trait :credit_month3 do
      transaction_date { Date.today.at_beginning_of_month - 3.months }
    end
  end
end
