# Note: There is a load path issue with `SamlIdp::IdpController` that occurs
#       if this controller is modified and you then visit the provider login page.
#       The error is "Unable to autoload constant SamlIdp::IdpController".
#       To prevent this, restart your server after modifying this file.
#
class SamlSessionsController < Devise::SamlSessionsController
  after_action :fetch_provider_details, only: :create

  def destroy
    sign_out current_provider
    if IdPSettingsAdapter.mock_saml?
      redirect_to providers_root_url
    else
      redirect_to idp_sign_out_provider_session_url(SAMLRequest: 1)
    end
  end

  private

  def fetch_provider_details
    current_provider.retrieve_details
  end

  # :nocov:
  def set_flash_message(key, kind, options = {})
    return Rails.logger.info("Devise flash message suppressed: #{kind}") if key.to_sym == :notice

    super
  end
  # :nocov:
end
