module Flow
  module Steps
    module ProviderIncome
      UnemployedButHMRCFoundDataInterruptsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_unemployed_but_hmrc_found_data_interrupt_path(application) },
      )
    end
  end
end
