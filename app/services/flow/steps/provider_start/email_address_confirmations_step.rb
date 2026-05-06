module Flow
  module Steps
    module ProviderStart
      EmailAddressConfirmationsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_email_address_confirmation_path(application) },
        forward: :application_confirmations,
      )
    end
  end
end
