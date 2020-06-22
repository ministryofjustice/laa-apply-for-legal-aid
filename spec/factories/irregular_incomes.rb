FactoryBot.define do
  factory :irregular_income do
    legal_aid_application
    amount { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
    income_type { 'student_loan' }
    frequency { 'annual' }
  end
end
