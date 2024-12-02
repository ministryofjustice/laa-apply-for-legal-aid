module Flow
  module Steps
    module ProviderStart
      ChangeOfNamesInterruptsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_change_of_names_interrupt_path(application) },
      )
    end
  end
end
