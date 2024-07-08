module Flow
  module Steps
    module ProviderProceedingLoop
      SubstantiveDefaultsStep = Step.new(
        path: lambda do |application|
          proceeding = application.provider_step_params["id"]
          Steps.urls.providers_legal_aid_application_substantive_default_path(application, proceeding)
        end,
        forward: lambda do |application|
          proceeding = Proceeding.find(application.provider_step_params["id"])
          if proceeding.accepted_substantive_defaults || proceeding.special_childrens_act?
            Flow::ProceedingLoop.next_step(application)
          else
            :substantive_level_of_service
          end
        end,
        carry_on_sub_flow: true,
        check_answers: :check_provider_answers,
      )
    end
  end
end
