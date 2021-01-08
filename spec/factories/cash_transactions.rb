FactoryBot.define do
  factory :cash_transaction do
    legal_aid_application
    transaction_type
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }

    trait :credit_month_1 do
      transaction_date { Date.today.at_beginning_of_month - 1.months }
    end

    trait :credit_month_2 do
      transaction_date { Date.today.at_beginning_of_month - 2.months }
    end

    trait :credit_month_3 do
      transaction_date { Date.today.at_beginning_of_month - 3.months }
    end
  end
end
