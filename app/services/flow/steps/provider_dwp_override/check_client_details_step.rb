module Flow
  module Steps
    module ProviderDWPOverride
      CheckClientDetailsStep = Step.new(
        ->(application) { Flow::Steps.urls.providers_legal_aid_application_check_client_details_path(application) },
        :received_benefit_confirmations,
        nil,
      )
    end
  end
end
