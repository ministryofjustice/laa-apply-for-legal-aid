module Flow
  module Steps
    module ProviderStart
      CheckBenefitsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_check_benefit_path(application) },
        forward: lambda do |application, dwp_override_non_passported|
          if application.applicant_receives_benefit?
            application.change_state_machine_type("PassportedStateMachine") unless ENV.fetch("EDITABLE_APPLICATIONS", "false") == "true"
            application.used_delegated_functions? ? :substantive_applications : :capital_introductions
          else
            application.change_state_machine_type("NonPassportedStateMachine") unless ENV.fetch("EDITABLE_APPLICATIONS", "false") == "true"
            dwp_override_non_passported ? :confirm_dwp_non_passported_applications : :applicant_employed
          end
        end,
      )
    end
  end
end
