module Flow
  module Steps
    module ProviderDWPOverride
      HasEvidenceOfBenefitsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_has_evidence_of_benefit_path(application) },
        forward: lambda do |application, has_evidence_of_benefit|
          if has_evidence_of_benefit
            application.change_state_machine_type("PassportedStateMachine") unless ENV.fetch("EDITABLE_APPLICATIONS", "false") == "true"
            application.used_delegated_functions? ? :substantive_applications : :capital_introductions
          else
            application.change_state_machine_type("NonPassportedStateMachine") unless ENV.fetch("EDITABLE_APPLICATIONS", "false") == "true"
            :about_financial_means
          end
        end,
      )
    end
  end
end
