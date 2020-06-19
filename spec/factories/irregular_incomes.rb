FactoryBot.define do
  factory :irregular_income do
    legal_aid_application
    income_type { 'student_loan' }
    frequency { 'annual' }
    amount { rand(1...10_000.0).round(2) }
  end
end
