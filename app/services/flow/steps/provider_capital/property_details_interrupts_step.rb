module Flow
  module Steps
    module ProviderCapital
      PropertyDetailsInterruptsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_means_property_details_interrupt_path(application) },
      )
    end
  end
end
