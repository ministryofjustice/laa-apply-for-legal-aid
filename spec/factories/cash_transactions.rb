FactoryBot.define do
  factory :cash_transaction do
    legal_aid_application
    transaction_type
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }

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
  end
end
