module Flow
  module Steps
    module ProviderProceedingLoop
      EmergencyScopeLimitationsStep = Step.new(
        path: lambda do |application|
          proceeding = Proceeding.find(application.provider_step_params["id"])
          Steps.urls.providers_legal_aid_application_emergency_scope_limitation_path(application, proceeding)
        end,
        forward: :substantive_defaults,
        carry_on_sub_flow: true,
        check_answers: :check_provider_answers,
      )
    end
  end
end
