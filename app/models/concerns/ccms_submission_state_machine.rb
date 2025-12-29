module CCMSSubmissionStateMachine
  extend ActiveSupport::Concern

  def blocked_by_lead_case_submission?
    return false if legal_aid_application.lead_application.nil? ||
      legal_aid_application.lead_application&.ccms_submission&.aasm_state.in?(%w[case_created completed])

    true
  end

  included do
    include AASM

    aasm do
      state :initialised, initial: true
      state :case_ref_obtained
      state :applicant_submitted
      state :applicant_ref_obtained
      state :document_ids_obtained
      state :lead_application_pending
      state :case_submitted
      state :case_created
      state :completed
      state :failed
      state :abandoned

      event :obtain_case_ref do
        transitions from: :initialised, to: :lead_application_pending, guard: :blocked_by_lead_case_submission?
        transitions from: :initialised, to: :case_ref_obtained
      end

      event :restart_linked_application do
        transitions from: :lead_application_pending, to: :case_ref_obtained, unless: :blocked_by_lead_case_submission?
      end

      event :submit_applicant do
        transitions from: :case_ref_obtained, to: :applicant_submitted
      end

      event :obtain_applicant_ref do
        transitions from: :applicant_submitted, to: :applicant_ref_obtained
        transitions from: :case_ref_obtained, to: :applicant_ref_obtained
      end

      event :obtain_document_ids do
        transitions from: :applicant_ref_obtained, to: :document_ids_obtained
      end

      event :submit_case do
        transitions from: :applicant_ref_obtained, to: :case_submitted
        transitions from: :document_ids_obtained, to: :case_submitted
      end

      event :confirm_case_created do
        transitions from: :case_submitted, to: :case_created
      end

      event :complete do
        transitions from: :case_created, to: :completed,
                    after: proc {
                      legal_aid_application.submitted_assessment!
                      if legal_aid_application.associated_applications.any?
                        legal_aid_application.associated_applications.each do |associated_application|
                          associated_application.ccms_submission.restart_linked_application! if associated_application.ccms_submission.lead_application_pending?
                        end
                      end
                    }
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

      event :abandon do
        transitions from: :initialised, to: :abandoned
        transitions from: :case_ref_obtained, to: :abandoned
        transitions from: :applicant_submitted, to: :abandoned
        transitions from: :applicant_ref_obtained, to: :abandoned
        transitions from: :case_submitted, to: :abandoned
        transitions from: :case_created, to: :abandoned
        transitions from: :document_ids_obtained, to: :abandoned
        transitions from: :restart_linked_application, to: :abandoned
      end
    end
  end
end
