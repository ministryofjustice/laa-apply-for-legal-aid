FactoryBot.define do
  factory :submission, class: CCMS::Submission do
    legal_aid_application { create :legal_aid_application }

    trait :case_ref_obtained do
      aasm_state { 'case_ref_obtained' }
    end
  end
end
