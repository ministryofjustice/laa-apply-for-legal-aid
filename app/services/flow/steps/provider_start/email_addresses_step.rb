module Flow
  module Steps
    module ProviderStart
      EmailAddressesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_email_address_path(application) },
        forward: :about_the_financial_assessments,
      )
    end
  end
end
