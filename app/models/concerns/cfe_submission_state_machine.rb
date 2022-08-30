module CFESubmissionStateMachine
  extend ActiveSupport::Concern

  included do
    include AASM

    aasm do
      state :initialised, initial: true
      state :assessment_created
      state :in_progress
      state :results_obtained
      state :failed
      state :cfe_not_called

      event :assessment_created do
        transitions from: :initialised, to: :assessment_created
      end

      event :cfe_not_called do
        transitions from: :initialised, to: :cfe_not_called
      end

      event :in_progress do
        transitions from: :assessment_created, to: :in_progress
        transitions from: :in_progress, to: :in_progress
      end

      event :results_obtained do
        transitions from: :in_progress, to: :results_obtained
      end

      event :fail do
        transitions from: :initialised, to: :failed
        transitions from: :assessment_created, to: :failed
        transitions from: :in_progress, to: :failed
        transitions from: :cfe_not_called, to: :failed
      end
    end
  end
end
