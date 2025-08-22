module Flow
  module Steps
    module ProviderDWP
      DWPOverridesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_dwp_override_path(application) },
        forward: lambda do |application, confirm_receipt_of_benefit|
          if confirm_receipt_of_benefit
            application.change_state_machine_type("PassportedStateMachine")
            :received_benefit_confirmations
          else
            application.change_state_machine_type("NonPassportedStateMachine")
            :about_financial_means
          end
        end,
      )
    end
  end
end
