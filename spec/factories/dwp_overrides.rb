FactoryBot.define do
  factory :dwp_override do
    legal_aid_application

    passporting_benefit { 'universal_credit' }
    has_evidence_of_benefit { nil }

    trait :with_no_evidence do
      has_evidence_of_benefit { false }
    end

    trait :with_evidence do
      has_evidence_of_benefit { true }
    end
  end
end
