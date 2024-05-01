module Flow
  module Flows
    class ProviderProceedingLoop < FlowSteps
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
        substantive_scope_limitations: {
          path: lambda do |application|
            proceeding = Proceeding.find(application.provider_step_params["id"])
            urls.providers_legal_aid_application_substantive_scope_limitation_path(application, proceeding)
          end,
          forward: ->(application) { Flow::ProceedingLoop.next_step(application) },
          carry_on_sub_flow: true,
          check_answers: :check_provider_answers,
        },
      }.freeze
    end
  end
end
