module Providers
  class InvalidLoginsController < ProviderBaseController
    legal_aid_application_not_required!

    def show
      @provider = Provider.find(current_provider.id)
      @portal_url = portal_url
      session['signed_out'] = true
      session['feedback_return_path'] = destroy_provider_session_path
      sign_out current_provider
    end

    private

    def portal_url
      uri = URI(Rails.configuration.x.laa_portal.idp_sso_target_url)
      "#{uri.scheme}://#{uri.host}"
    end
  end
end
