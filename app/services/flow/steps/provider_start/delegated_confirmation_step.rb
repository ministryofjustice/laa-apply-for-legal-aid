module Flow
  module Steps
    module ProviderStart
      DelegatedConfirmationStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_delegated_confirmation_index_path(application) },
      )
    end
  end
end
