module Flow
  module Steps
    module ProviderIncome
      MultipleEmploymentsInterruptsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_multiple_employments_interrupt_path(application) },
      )
    end
  end
end
