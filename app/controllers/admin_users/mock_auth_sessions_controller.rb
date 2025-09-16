module AdminUsers
  class MockAuthSessionsController < Devise::SessionsController
    def create
      if mock_auth_session_params[:email] == Rails.configuration.x.admin_omniauth.mock_username &&
          mock_auth_session_params[:password] == Rails.configuration.x.admin_omniauth.mock_password
        @admin_user = AdminUser.from_omniauth(auth_data)
        flash[:notice] = I18n.t "devise.sessions.signed_in"
        sign_in_and_redirect @admin_user, event: :authentication
      else
        flash[:notice] = I18n.t("devise.failure.invalid", authentication_keys: "email")
        render :new
      end
    end

  protected

    def mock_auth_session_params
      params.expect(admin_user: %i[email password])
    end

    # TODO: we could potentially use a hash of auth data then call auth_data[mock_auth_session_params[:email]] to
    # allow for multiple different mock users/providers here.
    def auth_data
      OmniAuth::Strategies::AdminLogin.mock_auth
    end

    def after_sign_in_path_for(_resource)
      admin_root_path
    end
  end
end
