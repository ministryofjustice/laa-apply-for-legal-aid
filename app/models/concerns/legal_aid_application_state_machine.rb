module LegalAidApplicationStateMachine
  extend ActiveSupport::Concern

  included do
    include AASM

    aasm column: :state do
      state :initiated, initial: true
      state :checking_client_details_answers
      state :client_details_answers_checked
      state :provider_submitted
      state :checking_citizen_answers
      state :checking_passported_answers
      state :means_completed
      state :checking_merits_answers
      state :merits_completed

      event :check_your_answers do
        transitions from: :initiated, to: :checking_client_details_answers
        transitions from: :client_details_answers_checked, to: :checking_client_details_answers
      end

      event :client_details_answers_checked do
        transitions from: :checking_client_details_answers, to: :client_details_answers_checked,
                    after: -> { CleanupCapitalAttributes.call(self) }
      end

      event :check_passported_answers do
        transitions from: :client_details_answers_checked, to: :checking_passported_answers
        transitions from: :means_completed, to: :checking_passported_answers
      end

      event :provider_submit do
        transitions from: :initiated, to: :provider_submitted
        transitions from: :checking_client_details_answers, to: :provider_submitted
        transitions from: :client_details_answers_checked, to: :provider_submitted
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
                    after: -> do
                      CleanupCapitalAttributes.call(self)
                      provider_step = Flow::KeyPoint.step_for(
                        journey: :providers,
                        key_point: :start_after_applicant_completes_means
                      )
                      update!(provider_step: provider_step)
                    end
        transitions from: :checking_passported_answers, to: :means_completed
      end

      event :check_merits_answers do
        transitions from: :means_completed, to: :checking_merits_answers
      end

      event :complete_merits do
        transitions from: :checking_merits_answers, to: :merits_completed
      end
    end
  end
end
