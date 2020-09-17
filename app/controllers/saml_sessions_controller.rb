# Note: There is a load path issue with `SamlIdp::IdpController` that occurs
#       if this controller is modified and you then visit the provider login page.
#       The error is "Unable to autoload constant SamlIdp::IdpController".
#       To prevent this, restart your server after modifying this file.
#
class SamlSessionsController < Devise::SamlSessionsController
  after_action :update_provider_details, only: :create

  def destroy # rubocop:disable Metrics/AbcSize
    puts ">>>>>>>>>>>> session destroy #{__FILE__}:#{__LINE__} <<<<<<<<<<<<\n"
    pp session.to_hash
    puts ">>>>>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<<<\n"
    sign_out current_provider

    puts ">>>>>>>>>>>> after signout #{__FILE__}:#{__LINE__} <<<<<<<<<<<<\n"
    pp session.to_hash
    puts ">>>>>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<<<\n"

    if IdPSettingsAdapter.mock_saml?
      redirect_to providers_root_url
    else
      redirect_to new_feedback_path
    end
  end

  def after_sign_in_path_for(_provider)
    providers_confirm_office_path
  end

  private

  def update_provider_details
    current_provider.update_details
  end

  # :nocov:
  def set_flash_message(key, kind, options = {})
    return Rails.logger.info("Devise flash message suppressed: #{kind}") if key.to_sym == :notice

    super
  end
  # :nocov:
end
