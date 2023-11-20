module Flow
  module Flows
    class ProviderDWPOverride < FlowSteps
      STEPS = {
        confirm_dwp_non_passported_applications: Flow::Steps::ConfirmDWPNonPassportedApplicationsStep,
        check_client_details: Flow::Steps::CheckClientDetailsStep,
        received_benefit_confirmations: Flow::Steps::ReceivedBenefitConfirmationsStep,
        has_evidence_of_benefits: Flow::Steps::HasEvidenceOfBenefitsStep,
      }.freeze
    end
  end
end
