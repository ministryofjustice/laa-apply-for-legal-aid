module CFESubmissionStateMachine
  extend ActiveSupport::Concern

  included do
    include AASM

    aasm do
      state :initialised, initial: true
      state :assessment_created
      state :applicant_created
      state :capitals_created
      state :vehicles_created
      state :properties_created
      state :results_obtained
      state :failed

      event :assessment_created do
        transitions from: :initialised, to: :assessment_created
      end

      event :applicant_created do
        transitions from: :assessment_created, to: :applicant_created
      end

      event :capitals_created do
        transitions from: :applicant_created, to: :capitals_created
      end

      event :vehicles_created do
        transitions from: :capitals_created, to: :vehicles_created
      end

      event :properties_created do
        transitions from: :vehicles_created, to: :properties_created
      end

      event :results_obtained do
        transitions from: :vehicles_created, to: :results_obtained
      end

      event :fail do
        transitions from: :initialised, to: :failed
        transitions from: :assessment_created, to: :failed
        transitions from: :applicant_created, to: :failed
        transitions from: :capitals_created, to: :failed
        transitions from: :properties_created, to: :failed
        transitions from: :vehicles_created, to: :failed
      end
    end
  end
end
