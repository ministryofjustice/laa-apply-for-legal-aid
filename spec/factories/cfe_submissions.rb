FactoryBot.define do
  factory :cfe_submission, class: CFE::Submission do
    legal_aid_application { create :legal_aid_application }

    trait :initialised do
      aasm_state { 'initialised' }
    end

    trait :assessment_created do
      aasm_state { 'assessment_created' }
    end
  end
end
