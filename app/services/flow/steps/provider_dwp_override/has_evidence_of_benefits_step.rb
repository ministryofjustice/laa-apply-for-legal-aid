module Flow
  module Steps
    module ProviderDWPOverride
      HasEvidenceOfBenefitsStep = Step.new(
        ->(application) { Flow::Steps.urls.providers_legal_aid_application_has_evidence_of_benefit_path(application) },
        lambda do |application, has_evidence_of_benefits|
          if has_evidence_of_benefits
            application.change_state_machine_type("PassportedStateMachine")
            application.used_delegated_functions? ? :substantive_applications : :capital_introductions
          else
            application.change_state_machine_type("NonPassportedStateMachine")
            :about_financial_means
          end
        end,
        nil,
      )
    end
  end
end
