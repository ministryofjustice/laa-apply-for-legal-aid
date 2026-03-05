module Flow
  module Steps
    module Partner
      NoNinoInterruptsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_partners_no_nino_interrupt_path(application) },
      )
    end
  end
end
