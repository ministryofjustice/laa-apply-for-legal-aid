FactoryBot.define do
  factory :chances_of_success, class: 'ProceedingMeritsTask::ChancesOfSuccess' do
    legal_aid_application

    trait :with_optional_text do
      application_purpose { Faker::Lorem.paragraph }
      proceedings_before_the_court { true }
      details_of_proceedings_before_the_court { Faker::Lorem.paragraph }
      success_prospect { 'marginal' }
      success_prospect_details { Faker::Lorem.paragraph }
      submitted_at { Faker::Time.backward }
    end

    trait :without_optional_text do
      application_purpose { nil }
      proceedings_before_the_court { false }
      details_of_proceedings_before_the_court { nil }
      success_prospect { 'likely' }
      success_prospect_details { nil }
      submitted_at { Faker::Time.backward }
    end
  end
end
