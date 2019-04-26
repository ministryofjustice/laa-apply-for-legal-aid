FactoryBot.define do
  factory :submission, class: CCMS::Submission do
    legal_aid_application { create :legal_aid_application }

    trait :initialised do
      aasm_state { 'initialised' }
    end

    trait :case_ref_obtained do
      aasm_state { 'case_ref_obtained' }
    end
  end
end
