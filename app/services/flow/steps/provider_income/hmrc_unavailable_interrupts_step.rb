module Flow
  module Steps
    module ProviderIncome
      HMRCUnavailableInterruptsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_hmrc_unavailable_interrupt_path(application) },
      )
    end
  end
end
