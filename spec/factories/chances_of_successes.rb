FactoryBot.define do
  factory :chances_of_success, class: 'ProceedingMeritsTask::ChancesOfSuccess' do
    trait :with_optional_text do
      application_purpose { Faker::Lorem.paragraph }
      success_prospect { 'marginal' }
      success_prospect_details { Faker::Lorem.paragraph }
    end

    trait :without_optional_text do
      application_purpose { nil }
      success_prospect { 'likely' }
      success_prospect_details { nil }
    end
  end
end
