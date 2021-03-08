module CFESubmissionStateMachine
  extend ActiveSupport::Concern

  # rubocop:disable Metrics/BlockLength
  included do
    include AASM

    aasm do
      state :initialised, initial: true
      state :assessment_created
      state :applicant_created
      state :capitals_created
      state :vehicles_created
      state :properties_created
      state :dependants_created
      state :outgoings_created
      state :state_benefits_created
      state :other_income_created
      state :irregular_income_created
      state :explicit_remarks_created
      state :cash_transactions_created
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

      event :dependants_created do
        transitions from: :explicit_remarks_created, to: :dependants_created, guard: :non_passported?
      end

      event :outgoings_created do
        transitions from: :dependants_created, to: :outgoings_created, guard: :non_passported?
      end

      event :state_benefits_created do
        transitions from: :outgoings_created, to: :state_benefits_created, guard: :non_passported?
      end

      event :other_income_created do
        transitions from: :state_benefits_created, to: :other_income_created, guard: :non_passported?
      end

      event :irregular_income_created do
        transitions from: :other_income_created, to: :irregular_income_created, guard: :non_passported?
      end

      event :cash_transactions_created do
        transitions from: :irregular_income_created, to: :cash_transactions_created, guard: :non_passported?
      end

      event :explicit_remarks_created do
        transitions from: :properties_created, to: :explicit_remarks_created
      end

      event :results_obtained do
        transitions from: :explicit_remarks_created, to: :results_obtained, guard: :passported?
        transitions from: :cash_transactions_created, to: :results_obtained, guard: :non_passported?
      end

      event :fail do
        transitions from: :initialised, to: :failed
        transitions from: :assessment_created, to: :failed
        transitions from: :applicant_created, to: :failed
        transitions from: :capitals_created, to: :failed
        transitions from: :properties_created, to: :failed
        transitions from: :vehicles_created, to: :failed
        transitions from: :dependants_created, to: :failed
        transitions from: :outgoings_created, to: :failed
        transitions from: :state_benefits_created, to: :failed
        transitions from: :other_income_created, to: :failed
        transitions from: :irregular_income_created, to: :failed
        transitions from: :explicit_remarks_created, to: :failed
        transitions from: :cash_transactions_created, to: :failed
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
