# This controller handles an admin user's return from the Google Oauth2 authentication
# Note that you may need to restart the server to apply changes to this file.
module AdminUsers
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def entra_id
      admin = AdminUser.from_omniauth(auth_data)
      if admin
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success"
        sign_in_and_redirect admin, event: :authentication
      else
        failure(reason: "You do not have an Admin account in this system")
      end
    end

    def failure(reason: "Process cancelled")
      set_flash_message(:error, reason:)
      redirect_to error_path(:access_denied)
    end

  protected

    def after_sign_in_path_for(resource)
      request.env["omniauth.origin"] || stored_location_for(resource) || admin_root_path
    end

  private

    def auth_data
      request.env["omniauth.auth"]
    end
  end
end
