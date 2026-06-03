module Flow
  module Steps
    module ProviderMerits
      OutOfScopeOfLaspoInterruptStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_out_of_scope_of_laspo_interrupt_path(application) },
      )
    end
  end
end
