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
          path: lambda do |application, first_visit|
            proceeding = if first_visit.nil?
                           Flow::ProceedingLoop.next_proceeding(application)
                         else
                           Proceeding.find(application.provider_step_params["id"])
                         end
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
      }.freeze
    end
  end
end
