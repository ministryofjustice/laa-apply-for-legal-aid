module Flow
  module Flows
    class ProviderProceedingLoop < FlowSteps
      STEPS = {
        client_involvement_type: {
          path: lambda do |application|
            proceeding = Flow::ProceedingLoop.next_proceeding(application)
            urls.providers_legal_aid_application_client_involvement_type_path(application, proceeding)
          end,
          forward: :delegated_functions,
          carry_on_sub_flow: false, # TODO: This may need changing when the full loop is implemented as a change of CIT affects the LOS and scopes, defaults and otherwise
          check_answers: :check_provider_answers,
        },
        delegated_functions: {
          path: lambda do |application|
            proceeding = application.provider_step_params["id"]
            urls.providers_legal_aid_application_delegated_function_path(application, proceeding)
          end,
          forward: ->(application) { Flow::ProceedingLoop.next_step(application) },
          carry_on_sub_flow: false, # TODO: This may need changing when the full loop is implemented as a change of DF affects the LOS and scopes, defaults and otherwise
          check_answers: lambda do |application|
            Flow::ProceedingLoop.next_step(application) == :confirm_delegated_functions_date ? :confirm_delegated_functions_date : :check_provider_answers
          end,
        },
        confirm_delegated_functions_date: {
          path: lambda do |application|
            # get the proceeding that has just been submitted, not the next `incomplete` one
            proceeding = Proceeding.find(application.provider_step_params["id"])
            urls.providers_legal_aid_application_confirm_delegated_functions_date_path(application, proceeding)
          end,
          forward: ->(application) { Flow::ProceedingLoop.next_step(application) },
          carry_on_sub_flow: false, # TODO: This may need changing when the full loop is implemented as a change of DF affects the LOS and scopes, defaults and otherwise
          check_answers: lambda do |application|
            Flow::ProceedingLoop.next_step(application) == :delegated_functions ? :delegated_functions : :check_provider_answers
          end,
        },
        emergency_defaults: {
          path: lambda do |application|
            proceeding = Proceeding.find(application.provider_step_params["id"])
            urls.providers_legal_aid_application_emergency_default_path(application, proceeding)
          end,
          forward: lambda do |application|
            proceeding = Proceeding.find(application.provider_step_params["id"])
            proceeding.accepted_emergency_defaults ? :substantive_defaults : :emergency_level_of_service
          end,
          carry_on_sub_flow: false, # TODO: This may need changing when the full loop is implemented as a change of DF affects the LOS and scopes, defaults and otherwise
          check_answers: :check_provider_answers,
        },
        substantive_defaults: {
          path: lambda do |application|
            proceeding = Proceeding.find(application.provider_step_params["id"])
            urls.providers_legal_aid_application_substantive_default_path(application, proceeding)
          end,
          forward: lambda do |application|
            proceeding = Proceeding.find(application.provider_step_params["id"])
            proceeding.accepted_substantive_defaults ? Flow::ProceedingLoop.next_step(application) : :substantive_level_of_service
          end,
          carry_on_sub_flow: false, # TODO: This may need changing when the full loop is implemented as a change of DF affects the LOS and scopes, defaults and otherwise
          check_answers: :check_provider_answers,
        },
        emergency_level_of_service: {
          path: lambda do |application|
            proceeding = Proceeding.find(application.provider_step_params["id"])
            urls.providers_legal_aid_application_emergency_level_of_service_path(application, proceeding)
          end,
          forward: :substantive_defaults,
          carry_on_sub_flow: false, # TODO: This may need changing when the full loop is implemented as a change of DF affects the LOS and scopes, defaults and otherwise
          check_answers: :check_provider_answers,
        },
        substantive_level_of_service: {
          path: lambda do |application|
            proceeding = Proceeding.find(application.provider_step_params["id"])
            urls.providers_legal_aid_application_substantive_level_of_service_path(application, proceeding)
          end,
          forward: ->(application) { Flow::ProceedingLoop.next_step(application) },
          carry_on_sub_flow: false, # TODO: This may need changing when the full loop is implemented as a change of DF affects the LOS and scopes, defaults and otherwise
          check_answers: :check_provider_answers,
        },
      }.freeze
    end
  end
end
