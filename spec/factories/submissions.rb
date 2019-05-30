FactoryBot.define do
  factory :submission, class: CCMS::Submission do
    legal_aid_application { create :legal_aid_application }

    trait :case_ref_obtained do
      aasm_state { 'case_ref_obtained' }
    end

    trait :applicant_submitted do
      aasm_state { 'applicant_submitted' }
    end

    trait :applicant_ref_obtained do
      aasm_state { 'applicant_ref_obtained' }
    end

    trait :case_submitted do
      aasm_state { 'case_submitted' }
    end

    trait :case_created do
      aasm_state { 'case_created' }
    end
  end
end
