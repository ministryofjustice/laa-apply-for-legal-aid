module LegalAidApplicationStateMachine
  extend ActiveSupport::Concern

  included do # rubocop:disable Metrics/BlockLength
    include AASM

    aasm column: :state do
      state :initiated, initial: true
      state :checking_client_details_answers
      state :client_details_answers_checked
      state :delegated_functions_used
      state :provider_submitted
      state :checking_citizen_answers
      state :checking_passported_answers
      state :means_completed
      state :provider_checking_citizens_means_answers
      state :provider_checked_citizens_means_answers
      state :checking_merits_answers
      state :checked_merits_answers
      state :assessment_submitted

      event :check_your_answers do
        transitions from: :initiated, to: :checking_client_details_answers
        transitions from: :client_details_answers_checked, to: :checking_client_details_answers
      end

      event :client_details_answers_checked do
        transitions from: :checking_client_details_answers, to: :client_details_answers_checked,
                    after: -> { CleanupCapitalAttributes.call(self) }
      end

      event :provider_used_delegated_functions do
        transitions from: :client_details_answers_checked, to: :delegated_functions_used
        transitions from: :provider_submitted, to: :delegated_functions_used
        transitions from: :delegated_functions_used, to: :delegated_functions_used
      end

      event :check_passported_answers do
        transitions from: :delegated_functions_used, to: :checking_passported_answers
        transitions from: :client_details_answers_checked, to: :checking_passported_answers
        transitions from: :means_completed, to: :checking_passported_answers
      end

      event :provider_submit do
        transitions from: :initiated, to: :provider_submitted
        transitions from: :checking_client_details_answers, to: :provider_submitted
        transitions from: :client_details_answers_checked, to: :provider_submitted
        transitions from: :delegated_functions_used, to: :provider_submitted
      end

      event :reset do
        transitions from: :checking_client_details_answers, to: :initiated
        transitions from: :checking_citizen_answers, to: :provider_submitted
        transitions from: :checking_passported_answers, to: :client_details_answers_checked
        transitions from: :checking_merits_answers, to: :means_completed
        transitions from: :means_completed, to: :checking_citizen_answers
      end

      event :check_citizen_answers do
        transitions from: :provider_submitted, to: :checking_citizen_answers
        transitions from: :means_completed, to: :checking_citizen_answers
      end

      event :complete_means do
        transitions from: :checking_citizen_answers, to: :means_completed,
                    after: -> { ApplicantCompleteMeans.call(self) }
        transitions from: :checking_passported_answers, to: :means_completed
      end

      event :provider_check_citizens_means_answers do
        transitions from: :means_completed, to: :provider_checking_citizens_means_answers
        transitions from: :provider_checked_citizens_means_answers, to: :provider_checking_citizens_means_answers
      end

      event :provider_checked_citizens_means_answers do
        transitions from: :provider_checking_citizens_means_answers, to: :provider_checked_citizens_means_answers
      end

      event :check_merits_answers do
        transitions from: :provider_checked_citizens_means_answers, to: :checking_merits_answers
        transitions from: :checked_merits_answers, to: :checking_merits_answers
        transitions from: :means_completed, to: :checking_merits_answers
        transitions from: :assessment_submitted, to: :checking_merits_answers
      end

      event :checked_merits_answers do
        transitions from: :checking_merits_answers, to: :checked_merits_answers
      end

      event :submit_assessment do
        transitions from: :checked_merits_answers, to: :assessment_submitted
      end
    end
  end
end
