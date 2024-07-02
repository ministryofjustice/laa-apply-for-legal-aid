module Flow
  module Steps
    module ProviderStart
      CheckProviderAnswersStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_check_provider_answers_path(application) },
        forward: lambda do |application|
          if application.under_16_blocked?
            :use_ccms_under16s
          elsif application.non_means_tested?
            application.change_state_machine_type("NonMeansTestedStateMachine")
            :confirm_non_means_tested_applications
          else
            application.applicant.national_insurance_number? ? :check_benefits : :no_national_insurance_numbers
          end
        end,
      )
    end
  end
end
