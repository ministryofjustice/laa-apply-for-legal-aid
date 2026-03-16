module Flow
  module Steps
    module Partner
      HMRCUnavailableInterruptsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_partners_hmrc_unavailable_interrupt_path(application) },
      )
    end
  end
end
