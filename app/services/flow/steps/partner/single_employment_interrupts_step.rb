module Flow
  module Steps
    module Partner
      SingleEmploymentInterruptsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_partners_single_employment_interrupt_path(application) },
      )
    end
  end
end
