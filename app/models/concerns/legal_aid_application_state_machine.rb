module LegalAidApplicationStateMachine
  extend ActiveSupport::Concern

  included do
    include AASM

    aasm column: :state do
      state :initiated, initial: true
      state :checking_answers
      state :answers_checked
      state :provider_submitted
      state :checking_citizen_answers
      state :means_completed

      event :check_your_answers do
        transitions from: :initiated, to: :checking_answers
        transitions from: :answers_checked, to: :checking_answers
      end

      event :answers_checked do
        transitions from: :checking_answers, to: :answers_checked
      end

      event :provider_submit do
        transitions from: :initiated, to: :provider_submitted
        transitions from: :checking_answers, to: :provider_submitted
        transitions from: :answers_checked, to: :provider_submitted
      end

      event :reset do
        transitions from: :checking_answers, to: :initiated
        transitions from: :checking_citizen_answers, to: :provider_submitted
      end

      event :check_citizen_answers do
        transitions from: :provider_submitted, to: :checking_citizen_answers
        transitions from: :means_completed, to: :checking_citizen_answers
      end

      event :complete_means do
        transitions from: :checking_citizen_answers, to: :means_completed
      end
    end
  end
end
