FactoryBot.define do
  factory :applicant do
    transient do
      num_bank_accounts { 0 }
    end

    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    date_of_birth { Faker::Date.birthday }
    email { Faker::Internet.safe_email }
    national_insurance_number { Faker::Base.regexify(Applicant::NINO_REGEXP) }
    uses_online_banking { [true, false].sample }

    trait :with_address do
      addresses { build_list :address, 1 }
    end

    trait :with_address_lookup do
      addresses { build_list :address, 1, :is_lookup_used }
    end

    trait :with_true_layer_tokens do
      after(:create) do |applicant|
        applicant.store_true_layer_token(
          token: SecureRandom.hex,
          expires: 1.hour.from_now
        )
      end
    end

    after(:create) do |applicant, evaluator|
      if evaluator.num_bank_accounts > 0
        provider = create :bank_provider, applicant: applicant
        evaluator.num_bank_accounts.times do
          create :bank_account, bank_provider: provider
        end
      end
    end
  end
end
