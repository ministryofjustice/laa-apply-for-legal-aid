# Note: There is a load path issue with `SamlIdp::IdpController` that occurs
#       if this controller is modified and you then visit the provider login page.
#       The error is "Unable to autoload constant SamlIdp::IdpController".
#       To prevent this, restart your server after modifying this file.
#
class SamlSessionsController < Devise::SamlSessionsController
  before_action :update_locale
  after_action :update_provider_details, only: :create, if: -> { response.successful? }

  def destroy
    session['signed_out'] = true
    session['feedback_return_path'] = destroy_provider_session_path
    sign_out current_provider
    if IdPSettingsAdapter.mock_saml?
      redirect_to providers_root_url
    else
      redirect_to new_feedback_path
    end
  end

  def create
    # Calls the create method in devise
    super
  rescue StandardError => e
    # redirects to access denied as providers_invalid_login_path expects there to be a provider.
    redirect_to error_path(:access_denied)
  end

  def after_sign_in_path_for(_provider)
    session[:journey_type] = :providers
    providers_confirm_office_path
  end

  private

  def update_provider_details
    ProviderAfterLoginService.call(current_provider)
  end

  # :nocov:
  def set_flash_message(key, kind, options = {})
    return Rails.logger.info("Devise flash message suppressed: #{kind}") if key.to_sym == :notice

    super
  end
  # :nocov:

  def current_user
    current_provider
  end

  def update_locale
    I18n.locale = I18n.default_locale
  end
end
