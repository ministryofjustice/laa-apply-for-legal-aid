FactoryBot.define do
  factory :partner do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    date_of_birth { Faker::Date.birthday }
    has_national_insurance_number { true }
    national_insurance_number { "JA123456D" }
    shared_benefit_with_applicant { false }
    legal_aid_application
    student_finance { nil }
    student_finance_amount { nil }

    trait :not_employed do
      employed { false }
      self_employed { false }
      armed_forces { false }
    end

    trait :employed do
      employed { true }
    end

    trait :under_18 do
      date_of_birth { 18.years.ago + 1.day }
    end

    trait :under_18_for_means_test_purposes do
      age_for_means_test_purposes { 17 }
    end

    trait :under_18_as_of do
      transient do
        as_of { Date.current }
      end

      date_of_birth { 18.years.ago(as_of) + 1.day }
    end

    trait :under_16 do
      date_of_birth { 16.years.ago + 1.day }
    end

    trait :with_shared_benefit do
      shared_benefit_with_applicant { true }
    end

    trait :no_nino do
      national_insurance_number { nil }
      has_national_insurance_number { false }
    end

    trait :with_full_employment_information do
      full_employment_details { Faker::Lorem.paragraph(sentence_count: 2) }
    end

    trait :with_extra_employment_information do
      extra_employment_information { true }
      extra_employment_information_details { Faker::Lorem.paragraph(sentence_count: 2) }
    end
  end
end
