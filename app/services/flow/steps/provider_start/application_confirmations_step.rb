module Flow
  module Steps
    module ProviderStart
      ApplicationConfirmationsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_application_confirmation_path(application) },
      )
    end
  end
end
