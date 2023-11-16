module Flow
  module Steps
    ConfirmDWPNonPassportedApplicationsStep = Step.new(
      ->(application) { urls.providers_legal_aid_application_confirm_dwp_non_passported_applications_path(application) },
      lambda do |application, confirm_dwp_non_passported|
        if confirm_dwp_non_passported
          application.change_state_machine_type("NonPassportedStateMachine")
          :about_financial_means
        else
          application.change_state_machine_type("PassportedStateMachine")
          :check_client_details
        end
      end,
      nil,
    )
  end
end
