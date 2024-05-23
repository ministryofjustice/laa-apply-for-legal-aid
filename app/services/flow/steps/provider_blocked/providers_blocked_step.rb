module Flow
  module Steps
    module ProviderBlocked
      ProvidersBlockedStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_block_path(application) },
      )
    end
  end
end
