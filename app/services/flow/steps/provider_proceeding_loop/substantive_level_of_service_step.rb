module Flow
  module Steps
    module ProviderProceedingLoop
      SubstantiveLevelOfServiceStep = Step.new(
        path: lambda do |application|
          proceeding = application.provider_step_params["id"]
          Steps.urls.providers_legal_aid_application_substantive_level_of_service_path(application, proceeding)
        end,
        forward: lambda do |_application, options|
          if options[:changed_to_full_rep]
            :final_hearings
          else
            :substantive_scope_limitations
          end
        end,
        carry_on_sub_flow: true,
        check_answers: :check_provider_answers,
      )
    end
  end
end
