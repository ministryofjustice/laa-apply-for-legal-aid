module CFESubmissionStateMachine
  extend ActiveSupport::Concern

  included do
    include AASM

    aasm do
      state :initialised, initial: true
      state :assessment_created
      state :applicant_created
      state :capitals_created
      state :properties_created
      state :vehicles_created
      state :results_obtained
      state :failed

      event :create_assessment do
        # before { CFE::CreateAssessmentService.call(self) }
        transitions from: :initialised, to: :assessment_created
        # transitions from: :failed, to: :failed
      end

      event :create_applicant do
        before { CFE::CreateApplicantService.call(self) }
        transitions from: :assessment_created, to: :applicant_created
      end

      event :create_capitals do
        before { CFE::CreateCapitalsService.call(self) }
        transitions from: :applicant_created, to: :capitals_created
      end

      event :create_properties do
        before { CFE::CreatePropertiesService.call(self) }
        transitions from: :capitals_created, to: :properties_created
      end

      event :create_vehicles do
        before { CFE::CreateVehiclesService.call(self) }
        transitions from: :properties_created, to: :vehicles_created
      end

      event :obtain_results do
        before { CFE::CreateObtainResultsService.call(self) }
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
