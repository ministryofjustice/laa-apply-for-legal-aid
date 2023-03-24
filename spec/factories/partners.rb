FactoryBot.define do
  factory :partner do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    date_of_birth { Faker::Date.birthday }
    has_national_insurance_number { true }
    national_insurance_number { "JA123456D" }
    legal_aid_application

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

    trait :with_address do
      address_line_one { Faker::Address.building_number }
      address_line_two { Faker::Address.street_address }
      city { Faker::Address.city }
      county { Faker::Address.city }
      postcode { ["SW10 9LB", "W6 0LQ", "SW1A 1AA", "RG2 7PU", "BH22 7HR"].sample }
    end
  end
end
