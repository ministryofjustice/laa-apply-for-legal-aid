module CCMSSubmissionStateMachine
  extend ActiveSupport::Concern

  included do
    include AASM

    aasm do
      state :initialised, initial: true
      state :case_ref_obtained
      state :applicant_submitted
      state :applicant_ref_obtained
      state :case_submitted
      state :case_created
      state :document_ids_obtained
      state :completed
      state :failed

      event :obtain_case_ref, after: :process_async! do
        transitions from: :initialised, to: :case_ref_obtained
      end

      event :submit_applicant, after: :process_async! do
        transitions from: :case_ref_obtained, to: :applicant_submitted
      end

      event :obtain_applicant_ref, after: :process_async! do
        transitions from: :applicant_submitted, to: :applicant_ref_obtained
        transitions from: :case_ref_obtained, to: :applicant_ref_obtained
      end

      event :submit_case, after: :process_async! do
        transitions from: :applicant_ref_obtained, to: :case_submitted
        transitions from: :document_ids_obtained, to: :case_submitted
      end

      event :confirm_case_created, after: :process_async! do
        transitions from: :case_submitted, to: :case_created
      end

      event :obtain_document_ids, after: :process_async! do
        transitions from: :applicant_ref_obtained, to: :document_ids_obtained
      end

      event :complete do
        transitions from: :case_created, to: :completed
      end

      event :fail do
        transitions from: :initialised, to: :failed
        transitions from: :case_ref_obtained, to: :failed
        transitions from: :applicant_submitted, to: :failed
        transitions from: :applicant_ref_obtained, to: :failed
        transitions from: :case_submitted, to: :failed
        transitions from: :case_created, to: :failed
        transitions from: :document_ids_obtained, to: :failed
      end
    end
  end
end
