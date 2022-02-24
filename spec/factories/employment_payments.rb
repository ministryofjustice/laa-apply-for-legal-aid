FactoryBot.define do
  factory :employment_payment do
    employment
    sequence(:date) { |n| n.months.ago }
    gross { Faker::Number.within(range: 1000.01..2900.99).round(2) }
    benefits_in_kind { 0.0 }
    tax { Faker::Number.within(range: -842.01..-25.99).round(2) }
    national_insurance { Faker::Number.within(range: -342.01..-25.99).round(2) }
    net_employment_income { gross + tax + national_insurance }
  end
end
