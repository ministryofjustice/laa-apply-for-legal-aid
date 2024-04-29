module Flow
  module Steps
    module ProviderProceedingLoop
      ConfirmDelegatedFunctionsDateStep = Step.new(
        path: lambda do |application|
          proceeding = application.provider_step_params["id"]
          Steps.urls.providers_legal_aid_application_confirm_delegated_functions_date_path(application, proceeding)
        end,
        forward: ->(application) { Flow::ProceedingLoop.next_step(application) },
        carry_on_sub_flow: true,
        check_answers: lambda do |application|
          Flow::ProceedingLoop.next_step(application) == :delegated_functions ? :delegated_functions : :check_provider_answers
        end,
      )
    end
  end
end
