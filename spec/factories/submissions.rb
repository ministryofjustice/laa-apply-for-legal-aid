FactoryBot.define do
  factory :submission, class: CCMS::Submission do
    legal_aid_application { create :legal_aid_application }

    trait :initialised do
      aasm_state { 'initialised' }
    end
  end
end
