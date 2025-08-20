# This controller handles an admin user's return from the Google Oauth2 authentication
# Note that you may need to restart the server to apply changes to this file.
module AdminUsers
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def google_oauth2
      if admin_user
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", kind: "Google"
        sign_in_and_redirect admin_user, event: :authentication
      else
        failure(reason: "You do not have an Admin account in this system")
      end
    end

    def failure(reason: "Process cancelled")
      set_flash_message(:error, :failure, kind: "Google", reason:)
      redirect_to error_path(:access_denied)
    end

  protected

    def after_sign_in_path_for(resource)
      request.env["omniauth.origin"] || stored_location_for(resource) || admin_root_path
    end

  private

    def admin_user
      return @admin_user if defined?(@admin_user)

      @admin_user = AdminUser.find_by(email:)
    end

    def access_token
      request.env["omniauth.auth"]
    end

    def email
      access_token.info["email"]
    end
  end
end
