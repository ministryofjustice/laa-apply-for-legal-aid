module Flow
  module Steps
    module ProviderDWPOverride
      ConfirmDWPNonPassportedApplicationsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_confirm_dwp_non_passported_applications_path(application) },
        forward: lambda do |application, confirm_dwp_non_passported|
          if confirm_dwp_non_passported
            application.change_state_machine_type("NonPassportedStateMachine") unless ENV.fetch("EDITABLE_APPLICATIONS", "false") == "true"
            :about_financial_means
          else
            application.change_state_machine_type("PassportedStateMachine") unless ENV.fetch("EDITABLE_APPLICATIONS", "false") == "true"
            :check_client_details
          end
        end,
      )
    end
  end
end
