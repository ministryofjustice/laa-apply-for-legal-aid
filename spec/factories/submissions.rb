FactoryBot.define do
  factory :submission, class: CCMS::Submission do
    legal_aid_application { create :legal_aid_application }
    sequence(:case_ccms_reference) { |n| format('300000%06d', n) }

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

    trait :document_ids_obtained do
      aasm_state { 'document_ids_obtained' }
      documents { [{ id: '12345', status: :id_obtained, type: :statement_of_case, ccms_document_id: '67890' }] }
    end
  end
end
