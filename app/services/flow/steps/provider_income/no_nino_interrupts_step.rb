module Flow
  module Steps
    module ProviderIncome
      NoNinoInterruptsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_no_nino_interrupt_path(application) },
      )
    end
  end
end
