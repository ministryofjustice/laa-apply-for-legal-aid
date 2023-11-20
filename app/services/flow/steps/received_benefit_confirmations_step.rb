module Flow
  module Steps
    ReceivedBenefitConfirmationsStep = Step.new(
      ->(application) { urls.providers_legal_aid_application_received_benefit_confirmation_path(application) },
      lambda do |application, has_benefit|
        if has_benefit
          application.change_state_machine_type("PassportedStateMachine")
          :has_evidence_of_benefits
        else
          application.change_state_machine_type("NonPassportedStateMachine")
          :about_financial_means
        end
      end,
      nil,
    )
  end
end
