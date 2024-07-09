module Flow
  module Steps
    module ProviderDWPOverride
      ReceivedBenefitConfirmationsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_received_benefit_confirmation_path(application) },
        forward: lambda do |application, has_benefit|
          if has_benefit
            application.change_state_machine_type("PassportedStateMachine")
            :has_evidence_of_benefits
          else
            application.change_state_machine_type("NonPassportedStateMachine")
            :about_financial_means
          end
        end,
      )
    end
  end
end
