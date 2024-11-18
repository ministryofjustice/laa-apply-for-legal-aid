module Flow
  module Steps
    module ProceedingsSCA
      InterruptsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_sca_interrupt_path(application, application.provider_step_params["type"]) },
      )
    end
  end
end
