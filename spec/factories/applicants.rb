FactoryBot.define do
  factory :applicant do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    date_of_birth { Faker::Date.birthday }
    email { Faker::Internet.safe_email }
    national_insurance_number { Faker::Base.regexify(Applicant::NINO_REGEXP) }
    employed { false }

    trait :with_address do
      addresses { build_list :address, 1 }
    end

    trait :with_address_for_xml_fixture do
      addresses { build_list :address, 1, :with_address_for_xml_fixture }
    end

    trait :with_address_lookup do
      addresses { build_list :address, 1, :is_lookup_used }
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

    trait :with_true_layer_tokens do
      after(:build) do |applicant|
        applicant.store_true_layer_token(
          token: SecureRandom.hex,
          expires: 1.hour.from_now,
        )
      end
    end

    trait :langley_yorke do
      first_name { 'Langley' }
      last_name { 'Yorke' }
      date_of_birth { Date.new(1992, 7, 22) }
      email { Faker::Internet.safe_email }
      national_insurance_number { 'MN212451D' }
    end

    # use :with_bank_accounts: 2 to create 2 bank accounts for the applicant
    transient do
      with_bank_accounts { 0 }
    end

    after(:build) do |applicant, evaluator|
      if evaluator.with_bank_accounts > 0
        provider = create :bank_provider, applicant: applicant
        evaluator.with_bank_accounts.times do
          create :bank_account, bank_provider: provider
        end
      end
    end
  end
end
