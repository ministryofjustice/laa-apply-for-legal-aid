FactoryBot.define do
  factory :applicant do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    date_of_birth { Faker::Date.birthday }
    email { Faker::Internet.email }
    has_national_insurance_number { true }
    national_insurance_number { "JA123456D" }
    employed { false }
    student_finance { nil }
    student_finance_amount { nil }
    changed_last_name { false }

    trait :with_only_correspondence_address do
      # TODO: delete this trait when Setting.home_address? is removed
      # Colin, 21 Jun 2024
      addresses { build_list(:address, 1) }
    end

    trait :with_address do
      same_correspondence_and_home_address { true }
      addresses { build_list(:address, 1, :as_home_address) }
    end

    trait :with_address_for_xml_fixture do
      same_correspondence_and_home_address { true }
      addresses { build_list(:address, 1, :as_home_address, :with_address_for_xml_fixture) }
    end

    trait :with_address_lookup do
      addresses { build_list(:address, 1, :is_lookup_used) }
    end

    trait :not_employed do
      employed { false }
      self_employed { false }
      armed_forces { false }
    end

    trait :employed do
      employed { true }
    end

    trait :self_employed do
      self_employed { true }
    end

    trait :armed_forces do
      armed_forces { true }
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

    trait :with_encrypted_true_layer_token do
      encrypted_true_layer_token do
        { token: SecureRandom.hex, expires_at: 1.hour.from_now }
      end
    end

    trait :with_student_finance do
      student_finance { true }
      student_finance_amount { 1234.56 }
    end

    trait :langley_yorke do
      first_name { "Langley" }
      last_name { "Yorke" }
      date_of_birth { Date.new(1992, 7, 22) }
      email { Faker::Internet.email }
      national_insurance_number { "MN212451D" }
    end

    trait :ida_paisley do
      first_name { "Ida" }
      last_name { "Paisley" }
      date_of_birth { Date.new(1987, 11, 24) }
      email { Faker::Internet.email }
      national_insurance_number { "OE726113A" }
    end

    trait :john_pending do
      first_name { "John" }
      last_name { "Pending" }
      date_of_birth { Date.new(2002, 9, 1) }
      email { Faker::Internet.email }
      national_insurance_number { "KY123456D" }
    end

    trait :john_jobseeker do
      not_employed
      first_name { "John" }
      last_name { "Jobseeker" }
      date_of_birth { Date.new(2005, 5, 5) }
      email { Faker::Internet.email }
      national_insurance_number { "BB123456B" }
    end

    trait :with_partner do
      has_partner { true }
    end

    trait :no_nino do
      national_insurance_number { nil }
      has_national_insurance_number { false }
    end

    trait :with_extra_employment_information do
      extra_employment_information { true }
      extra_employment_information_details { Faker::Lorem.paragraph(sentence_count: 2) }
    end

    trait :with_changed_last_name do
      changed_last_name { true }
      last_name_at_birth { Faker::Name.last_name }
    end

    # use :with_bank_accounts: 2 to create 2 bank accounts for the applicant
    transient do
      with_bank_accounts { 0 }
    end

    after(:build) do |applicant, evaluator|
      if evaluator.with_bank_accounts > 0
        provider = create(:bank_provider, applicant:)
        evaluator.with_bank_accounts.times do
          create(:bank_account, bank_provider: provider)
        end
      end
    end
  end
end
