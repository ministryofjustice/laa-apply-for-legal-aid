module Flow
  module Steps
    module ProviderDWP
      DWPResultsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_dwp_result_path(application) },
        forward: lambda do |application|
          application.change_state_machine_type("NonPassportedStateMachine")
          :dwp_fallback
        end,
      )
    end
  end
end
