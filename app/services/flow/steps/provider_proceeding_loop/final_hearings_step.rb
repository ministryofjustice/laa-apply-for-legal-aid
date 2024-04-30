module Flow
  module Steps
    module ProviderProceedingLoop
      FinalHearingsStep = Step.new(
        path: lambda do |application, options|
          proceeding = Proceeding.find(application.provider_step_params["id"])
          Steps.urls.providers_legal_aid_application_final_hearings_path(application, proceeding, options[:work_type])
        end,
        forward: lambda do |_application, options|
          options[:work_type].to_sym == :substantive ? :substantive_scope_limitations : :emergency_scope_limitations
        end,
        carry_on_sub_flow: true,
        check_answers: :check_provider_answers,
      )
    end
  end
end
