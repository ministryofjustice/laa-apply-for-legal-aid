module Flow
  module Steps
    module ProviderDWP
      DWPPartnerOverridesStep = Step.new(
        path: ->(application) { Steps.urls.providers_legal_aid_application_dwp_partner_override_path(application) },
        forward: :check_client_details,
      )
    end
  end
end
