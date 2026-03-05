module Flow
  module Steps
    module Partner
      UnemployedButHMRCFoundDataInterruptsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_partners_unemployed_but_hmrc_found_data_interrupt_path(application) },
      )
    end
  end
end
