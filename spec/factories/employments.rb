FactoryBot.define do
  factory :employment do
    legal_aid_application
    sequence(:name) { |n| "Job #{n}" }

    trait :example1_usecase1 do
      id { "12345678-1234-1234-1234-123456789abc" }
      name { "Job 788" }

      after(:create) do |employment|
        create :employment_payment,
               id: "20211128-0000-0000-0000-123456789abc",
               employment: employment,
               date: Date.new(2021, 11, 28),
               gross: 1868.98,
               benefits_in_kind: 0.0,
               tax: -161.8,
               national_insurance: -128.64,
               net_employment_income: 1578.54

        create :employment_payment,
               id: "20211028-0000-0000-0000-123456789abc",
               employment: employment,
               date: Date.new(2021, 10, 28),
               gross: 1868.98,
               benefits_in_kind: 0.0,
               tax: -111,
               national_insurance: -128.64,
               net_employment_income: 1629.34

        create :employment_payment,
               id: "20210928-0000-0000-0000-123456789abc",
               employment: employment,
               date: Date.new(2021, 9, 28),
               gross: 2492.61,
               benefits_in_kind: 0.0,
               tax: -286.6,
               national_insurance: -203.47,
               net_employment_income: 2002.54

        create :employment_payment,
               id: "20210828-0000-0000-0000-123456789abc",
               employment: employment,
               date: Date.new(2021, 8, 28),
               gross: 2345.29,
               benefits_in_kind: 0.0,
               tax: -257.2,
               national_insurance: -185.79,
               net_employment_income: 1902.3
      end
    end
  end
end
