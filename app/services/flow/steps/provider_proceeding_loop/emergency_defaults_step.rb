module Flow
  module Steps
    module ProviderProceedingLoop
      EmergencyDefaultsStep = Step.new(
        path: lambda do |application|
          proceeding = application.provider_step_params["id"]
          Steps.urls.providers_legal_aid_application_emergency_default_path(application, proceeding)
        end,
        forward: lambda do |application|
          proceeding = Proceeding.find(application.provider_step_params["id"])
          proceeding.accepted_emergency_defaults ? :substantive_defaults : :emergency_level_of_service
        end,
        carry_on_sub_flow: true,
        check_answers: :check_provider_answers,
      )
    end
  end
end
