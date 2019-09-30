# This controller handles an admin user's return from the Google Oauth2 authentication
# Note that you may need to restart the server to apply changes to this file.
module AdminUsers
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_back_history_for :true_layer, :failure

    def google_oauth2
      if admin_user
        flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Google'
        sign_in_and_redirect admin_user, event: :authentication
      else
        failure(reason: 'You do not have an Admin account in this system')
      end
    end

    def failure(reason: 'Process cancelled')
      set_flash_message(:error, :failure, kind: 'Google', reason: reason)
      redirect_to root_path
    end

    private

    def admin_user
      @admin_user ||= AdminUser.find_by(email: email)
    end

    def access_token
      request.env['omniauth.auth']
    end

    def email
      access_token.info['email']
    end
  end
end
