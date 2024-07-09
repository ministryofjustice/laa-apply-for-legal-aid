module Flow
  module Flows
    class ProviderDWPOverride < FlowSteps
      STEPS = {
        confirm_dwp_non_passported_applications: Steps::ProviderDWPOverride::ConfirmDWPNonPassportedApplicationsStep,
        check_client_details: Steps::ProviderDWPOverride::CheckClientDetailsStep,
        received_benefit_confirmations: Steps::ProviderDWPOverride::ReceivedBenefitConfirmationsStep,
        has_evidence_of_benefits: Steps::ProviderDWPOverride::HasEvidenceOfBenefitsStep,
      }.freeze
    end
  end
end
