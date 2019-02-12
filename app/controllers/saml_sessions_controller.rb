# Note: There is a load path issue with `SamlIdp::IdpController` that occurs
#       if this controller is modified and you then visit the provider login page.
#       The error is "Unable to autoload constant SamlIdp::IdpController".
#       To prevent this, restart your server after modifying this file.
#
class SamlSessionsController < Devise::SamlSessionsController
  def destroy
    sign_out current_provider
    redirect_to providers_root_url
  end

  private

  # :nocov:
  def set_flash_message(key, kind, options = {})
    return Rails.logger.info("Devise flash message suppressed: #{kind}") if key.to_sym == :notice

    super
  end
  # :nocov:
end
