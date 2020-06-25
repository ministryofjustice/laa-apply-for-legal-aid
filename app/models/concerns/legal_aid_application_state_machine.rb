module LegalAidApplicationStateMachine # rubocop:disable Metrics/ModuleLength
  extend ActiveSupport::Concern

  included do # rubocop:disable Metrics/BlockLength
    include AASM

    def summary_state
      return :submitted if merits_assessment&.submitted_at

      :in_progress
    end

    def provider_checking_or_checked_citizens_means_answers?
      provider_checking_citizens_means_answers? || provider_checked_citizens_means_answers?
    end

    aasm column: :state do # rubocop:disable Metrics/BlockLength
      state :initiated, initial: true
      state :entering_applicant_details # new state between initiated and checking_applicant_detils/checking_client_details_answers
      state :checking_applicant_details # rename of checking_client_details_answers
      state :applicant_details_checked # rename of client_details_answers_checked

      # state :checking_client_details_answers # renamed to checking_applicant_details
      # state :client_details_answers_checked # renamed to applicant_details_checked
      state :delegated_functions_used
      state :provider_submitted
      state :checking_citizen_answers
      state :checking_passported_answers
      state :analysing_bank_transactions
      state :provider_assessing_means
      state :provider_checking_citizens_means_answers
      state :provider_checked_citizens_means_answers
      state :checking_merits_answers
      state :generating_reports
      state :submitting_assessment
      state :assessment_submitted
      state :use_ccms

      event :enter_applicant_details do
        transitions from: :initiated, to: :entering_applicant_details
      end

      event :check_applicant_details do
        transitions from: :entering_applicant_details, to: :checking_applicant_details
        transitions from: :applicant_details_checked, to: :checking_applicant_details
      end

      event :applicant_details_checked do
        transitions from: :checking_applicant_details, to: :applicant_details_checked,
                    after: -> { CleanupCapitalAttributes.call(self) }
      end

      event :provider_used_delegated_functions do
        transitions from: :applicant_details_checked, to: :delegated_functions_used
        transitions from: :provider_submitted, to: :delegated_functions_used
        transitions from: :delegated_functions_used, to: :delegated_functions_used
      end

      event :check_passported_answers do
        transitions from: :delegated_functions_used, to: :checking_passported_answers
        transitions from: :applicant_details_checked, to: :checking_passported_answers
        transitions from: :provider_assessing_means, to: :checking_passported_answers
      end

      event :provider_submit do
        transitions from: :initiated, to: :provider_submitted
        transitions from: :entering_applicant_details, to: :provider_submitted # this will be removed eventually
        transitions from: :checking_applicant_details, to: :provider_submitted
        transitions from: :applicant_details_checked, to: :provider_submitted
        transitions from: :delegated_functions_used, to: :provider_submitted
        transitions from: :use_ccms, to: :provider_submitted
      end

      event :use_ccms do
        transitions from: :initiated, to: :use_ccms
        transitions from: :applicant_details_checked, to: :use_ccms
        transitions from: :provider_submitted, to: :use_ccms
        transitions from: :delegated_functions_used, to: :use_ccms
      end

      event :reset do
        transitions from: :checking_applicant_details, to: :entering_applicant_details
        transitions from: :checking_citizen_answers, to: :provider_submitted
        transitions from: :checking_passported_answers, to: :applicant_details_checked
        transitions from: :checking_merits_answers, to: :provider_assessing_means
        transitions from: :provider_assessing_means, to: :checking_citizen_answers
      end

      event :check_citizen_answers do
        transitions from: :provider_submitted, to: :checking_citizen_answers
        transitions from: :provider_assessing_means, to: :checking_citizen_answers
      end

      event :complete_means do
        transitions from: :checking_citizen_answers, to: :analysing_bank_transactions,
                    after: -> do
                      ApplicantCompleteMeans.call(self)
                      BankTransactionsAnalyserJob.perform_later(self)
                    end
        transitions from: :checking_passported_answers, to: :provider_assessing_means
      end

      event :complete_bank_transaction_analysis do
        transitions from: :analysing_bank_transactions, to: :provider_assessing_means
      end

      event :provider_check_citizens_means_answers do
        transitions from: :provider_assessing_means, to: :provider_checking_citizens_means_answers
        transitions from: :provider_checked_citizens_means_answers, to: :provider_checking_citizens_means_answers
      end

      event :provider_checked_citizens_means_answers do
        transitions from: :provider_checking_citizens_means_answers, to: :provider_checked_citizens_means_answers
      end

      event :check_merits_answers do
        transitions from: :provider_checked_citizens_means_answers, to: :checking_merits_answers
        transitions from: :checked_merits_answers, to: :checking_merits_answers
        transitions from: :provider_assessing_means, to: :checking_merits_answers
        transitions from: :submitting_assessment, to: :checking_merits_answers
        transitions from: :assessment_submitted, to: :checking_merits_answers
      end

      event :generate_reports do
        transitions from: :checking_merits_answers, to: :generating_reports,
                    after: -> do
                      ReportsCreatorWorker.perform_async(id)
                      PostSubmissionProcessingJob.perform_later(id, "#{Rails.configuration.x.application.host_url}/feedback/new")
                    end
      end

      event :generated_reports do
        transitions from: :generating_reports, to: :submitting_assessment,
                    after: -> do
                      ccms_submission.process_async! if Rails.configuration.x.ccms_soa.submit_applications_to_ccms
                    end
      end

      event :submitted_assessment do
        transitions from: :submitting_assessment, to: :assessment_submitted
      end

      event :reset_from_use_ccms do
        transitions from: :use_ccms, to: :initiated
      end
    end
  end
end
