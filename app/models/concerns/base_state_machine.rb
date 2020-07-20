class BaseStateMachine < ApplicationRecord
  self.table_name = 'state_machine_proxies'

  belongs_to :legal_aid_application

  include AASM

  aasm do # rubocop:disable Metrics/BlockLength
    state :initiated, initial: true
    state :entering_applicant_details
    state :checking_applicant_details
    state :applicant_details_checked
    state :provider_entering_merits
    state :checking_merits_answers
    state :generating_reports
    state :submitting_assessment
    state :assessment_submitted
    state :use_ccms
    state :delegated_functions_used

    event :enter_applicant_details do
      transitions from: %i[
        initiated
        applicant_details_checked
        provider_entering_means
        checking_applicant_details
        use_ccms
      ],
                  to: :entering_applicant_details
    end

    event :check_applicant_details do
      transitions from: %i[
        entering_applicant_details
        applicant_details_checked
        use_ccms
      ],
                  to: :checking_applicant_details
    end

    event :applicant_details_checked do
      transitions from: %i[
        checking_applicant_details
        provider_confirming_applicant_eligibility
      ],
                  to: :applicant_details_checked,
                  after: proc { |legal_aid_application| CleanupCapitalAttributes.call(legal_aid_application) }
    end

    event :provider_used_delegated_functions do
      transitions from: %i[
        applicant_details_checked
        delegated_functions_used
      ],
                  to: :delegated_functions_used
    end

    event :use_ccms do
      transitions from: %i[
        initiated
        applicant_details_checked
        delegated_functions_used
        provider_confirming_applicant_eligibility
        applicant_entering_means
        use_ccms
      ],
                  to: :use_ccms
    end

    event :reset do
      transitions from: :checking_applicant_details, to: :entering_applicant_details
      transitions from: :checking_citizen_answers, to: :applicant_entering_means
      transitions from: :checking_passported_answers, to: :provider_entering_means
      transitions from: :checking_merits_answers, to: :provider_entering_merits
    end

    event :provider_enter_merits do
      transitions from: :checking_non_passported_means, to: :provider_entering_merits
    end

    event :check_merits_answers do
      transitions from: %i[
        provider_entering_merits
        checked_merits_answers
        provider_entering_merits
        submitting_assessment
        assessment_submitted
      ],
                  to: :checking_merits_answers
    end

    event :generate_reports do
      transitions from: :checking_merits_answers, to: :generating_reports,
                  after: proc { |legal_aid_application|
                    ReportsCreatorWorker.perform_async(legal_aid_application.id)
                    PostSubmissionProcessingJob.perform_later(legal_aid_application.id, "#{Rails.configuration.x.application.host_url}/feedback/new")
                  }
    end

    event :generated_reports do
      transitions from: :generating_reports, to: :submitting_assessment,
                  after: proc { |legal_aid_application| legal_aid_application.ccms_submission.process_async! if Rails.configuration.x.ccms_soa.submit_applications_to_ccms }
    end

    event :submitted_assessment do
      transitions from: :submitting_assessment, to: :assessment_submitted
    end

    event :reset_from_use_ccms do
      transitions from: :use_ccms, to: :applicant_details_checked
    end
  end
end
