module Flow
  module Steps
    module ProviderProceedingLoop
      ClientInvolvementTypeStep = Step.new(
        path: lambda do |application|
          proceeding = application.provider_step_params["id"]
          Steps.urls.providers_legal_aid_application_client_involvement_type_path(application, proceeding)
        end,
        forward: ->(application) { Flow::ProceedingLoop.next_step(application) },
        carry_on_sub_flow: true,
        check_answers: :check_provider_answers,
      )
    end
  end
end
