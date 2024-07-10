module Flow
  module Steps
    module ProviderDWPOverride
      CheckClientDetailsStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_check_client_details_path(application) },
        forward: :received_benefit_confirmations,
      )
    end
  end
end
