module Flow
  module Steps
    module ProviderProceedingLoop
      DelegatedFunctionsStep = Step.new(
        path: lambda do |application|
          proceeding = application.provider_step_params["id"]
          Steps.urls.providers_legal_aid_application_delegated_function_path(application, proceeding)
        end,
        forward: ->(application) { Flow::ProceedingLoop.next_step(application) },
        carry_on_sub_flow: true,
        check_answers: lambda do |application|
          Flow::ProceedingLoop.next_step(application) == :confirm_delegated_functions_date ? :confirm_delegated_functions_date : :check_provider_answers
        end,
      )
    end
  end
end
