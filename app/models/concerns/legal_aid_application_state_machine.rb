# rubocop:disable Layout/FirstArrayElementIndentation
module LegalAidApplicationStateMachine # rubocop:disable Metrics/ModuleLength Layout/ArrayAlignment
  extend ActiveSupport::Concern

  included do # rubocop:disable Metrics/BlockLength
    include AASM

    def summary_state
      return :submitted if merits_assessment&.submitted_at

      :in_progress
    end

    def provider_checking_or_checked_citizens_means_answers?
      checking_non_passported_means? || provider_entering_merits?
    end

    aasm column: :state do # rubocop:disable Metrics/BlockLength
      state :analysing_bank_transactions
      state :applicant_details_checked
      state :applicant_entering_means
      state :assessment_submitted
      state :awaiting_applicant
      state :checking_applicant_details
      state :checking_citizen_answers
      state :checking_merits_answers
      state :checking_non_passported_means
      state :checking_passported_answers
      state :delegated_functions_used
      state :entering_applicant_details
      state :generating_reports
      state :initiated, initial: true
      state :provider_assessing_means
      state :provider_confirming_applicant_eligibility
      state :provider_entering_means
      state :provider_entering_merits
      state :submitting_assessment
      state :use_ccms

      event :enter_applicant_details do
        transitions from: %i[
                              initiated
                              applicant_details_checked
                              provider_entering_means
                              checking_applicant_details
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
                    after: -> { CleanupCapitalAttributes.call(self) }
      end

      event :provider_enter_means do
        transitions from: %i[
                              applicant_details_checked
                              delegated_functions_used
                              use_ccms
                            ],
                    to: :provider_entering_means
      end

      event :provider_used_delegated_functions do
        transitions from: %i[
                              applicant_details_checked
                              delegated_functions_used
                             ],
                    to: :delegated_functions_used
      end

      event :check_passported_answers do
        transitions  from: %i[
                                provider_entering_means
                                delegated_functions_used
                                delegated_functions_used
                              ],
                     to: :checking_passported_answers
      end

      event :use_ccms do
        transitions  from: %i[
                                initiated
                                applicant_details_checked
                                delegated_functions_used
                                provider_confirming_applicant_eligibility
                                applicant_entering_means
                                use_ccms
                             ],
                     to: :use_ccms
      end

      event :await_applicant do
        transitions from: :provider_confirming_applicant_eligibility, to: :awaiting_applicant
      end

      event :applicant_enter_means do
        transitions from: %i[
                              awaiting_applicant
                              applicant_entering_means
                              use_ccms
                            ],
                    to: :applicant_entering_means
      end

      event :reset do
        transitions from: :checking_applicant_details, to: :entering_applicant_details
        transitions from: :checking_citizen_answers, to: :applicant_entering_means
        transitions from: :checking_passported_answers, to: :provider_entering_means
        transitions from: :checking_merits_answers, to: :provider_entering_merits
      end

      event :check_citizen_answers do
        transitions from: :applicant_entering_means, to: :checking_citizen_answers
      end

      event :complete_non_passported_means do
        transitions from: :checking_citizen_answers, to: :analysing_bank_transactions,
                    after: -> do
                      ApplicantCompleteMeans.call(self)
                      BankTransactionsAnalyserJob.perform_later(self)
                    end
      end

      event :complete_passported_means do
        transitions from: :checking_passported_answers, to: :provider_entering_merits
      end

      event :complete_bank_transaction_analysis do
        transitions from: :analysing_bank_transactions, to: :provider_assessing_means
      end

      event :check_non_passported_means do
        transitions from: %i[
                              provider_assessing_means
                              provider_entering_merits
                            ],
                    to: :checking_non_passported_means
      end

      event :provider_enter_merits do
        transitions from: :checking_non_passported_means, to: :provider_entering_merits
      end

      event :provider_confirm_applicant_eligibility do
        transitions from: %i[
                              applicant_details_checked
                              delegated_functions_used
                            ],
                    to: :provider_confirming_applicant_eligibility
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
        transitions from: :use_ccms, to: :applicant_details_checked
      end
    end
  end
end
# rubocop:enable Layout/FirstArrayElementIndentation
