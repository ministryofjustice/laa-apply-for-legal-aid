module Flow
  module Steps
    module ProviderIncome
      EmployedButNoHMRCDataInterruptsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_employed_but_no_hmrc_data_interrupt_path(application) },
      )
    end
  end
end
