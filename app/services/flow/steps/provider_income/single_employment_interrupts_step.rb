module Flow
  module Steps
    module ProviderIncome
      SingleEmploymentInterruptsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_single_employment_interrupt_path(application) },
      )
    end
  end
end
