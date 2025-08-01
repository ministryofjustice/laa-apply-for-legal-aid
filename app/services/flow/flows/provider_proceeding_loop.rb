module Flow
  module Flows
    class ProviderProceedingLoop
      STEPS = {
        client_involvement_type: Steps::ProviderProceedingLoop::ClientInvolvementTypeStep,
        delegated_functions: Steps::ProviderProceedingLoop::DelegatedFunctionsStep,
        confirm_delegated_functions_date: Steps::ProviderProceedingLoop::ConfirmDelegatedFunctionsDateStep,
        emergency_defaults: Steps::ProviderProceedingLoop::EmergencyDefaultsStep,
        substantive_defaults: Steps::ProviderProceedingLoop::SubstantiveDefaultsStep,
        emergency_level_of_service: Steps::ProviderProceedingLoop::EmergencyLevelOfServiceStep,
        substantive_level_of_service: Steps::ProviderProceedingLoop::SubstantiveLevelOfServiceStep,
        final_hearings: Steps::ProviderProceedingLoop::FinalHearingsStep,
        emergency_scope_limitations: Steps::ProviderProceedingLoop::EmergencyScopeLimitationsStep,
        substantive_scope_limitations: Steps::ProviderProceedingLoop::SubstantiveScopeLimitationsStep,
      }.freeze
    end
  end
end
