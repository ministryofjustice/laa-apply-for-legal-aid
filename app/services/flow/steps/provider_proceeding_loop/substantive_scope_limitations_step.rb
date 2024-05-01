module Flow
  module Steps
    module ProviderProceedingLoop
      SubstantiveScopeLimitationsStep = Step.new(
        path: lambda do |application|
          proceeding = Proceeding.find(application.provider_step_params["id"])
          Steps.urls.providers_legal_aid_application_substantive_scope_limitation_path(application, proceeding)
        end,
        forward: ->(application) { Flow::ProceedingLoop.next_step(application) },
        carry_on_sub_flow: true,
        check_answers: :check_provider_answers,
      )
    end
  end
end
