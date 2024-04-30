module Flow
  module Flows
    class ProviderProceedingLoop < FlowSteps
      STEPS = {
        client_involvement_type: Steps::ProviderProceedingLoop::ClientInvolvementTypeStep,
        delegated_functions: Steps::ProviderProceedingLoop::DelegatedFunctionsStep,
        confirm_delegated_functions_date: Steps::ProviderProceedingLoop::ConfirmDelegatedFunctionsDateStep,
        emergency_defaults: Steps::ProviderProceedingLoop::EmergencyDefaultsStep,
        substantive_defaults: Steps::ProviderProceedingLoop::SubstantiveDefaultsStep,
        emergency_level_of_service: {
          path: lambda do |application|
            proceeding = Proceeding.find(application.provider_step_params["id"])
            urls.providers_legal_aid_application_emergency_level_of_service_path(application, proceeding)
          end,
          forward: lambda do |_application, options|
            if options[:changed_to_full_rep]
              :final_hearings
            else
              :emergency_scope_limitations
            end
          end,
          carry_on_sub_flow: true,
          check_answers: :check_provider_answers,
        },
        substantive_level_of_service: {
          path: lambda do |application|
            proceeding = Proceeding.find(application.provider_step_params["id"])
            urls.providers_legal_aid_application_substantive_level_of_service_path(application, proceeding)
          end,
          forward: lambda do |_application, options|
            if options[:changed_to_full_rep]
              :final_hearings
            else
              :substantive_scope_limitations
            end
          end,
          carry_on_sub_flow: true,
          check_answers: :check_provider_answers,
        },
        final_hearings: {
          path: lambda do |application, options|
            proceeding = Proceeding.find(application.provider_step_params["id"])
            urls.providers_legal_aid_application_final_hearings_path(application, proceeding, options[:work_type])
          end,
          forward: lambda do |_application, options|
            options[:work_type].to_sym == :substantive ? :substantive_scope_limitations : :emergency_scope_limitations
          end,
          carry_on_sub_flow: true,
          check_answers: :check_provider_answers,
        },
        emergency_scope_limitations: {
          path: lambda do |application|
            proceeding = Proceeding.find(application.provider_step_params["id"])
            urls.providers_legal_aid_application_emergency_scope_limitation_path(application, proceeding)
          end,
          forward: :substantive_defaults,
          carry_on_sub_flow: true,
          check_answers: :check_provider_answers,
        },
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
