module Flow
  module Steps
    module Partner
      EmployedButNoHMRCDataInterruptsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_partners_employed_but_no_hmrc_data_interrupt_path(application) },
      )
    end
  end
end
