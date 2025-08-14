module Providers
  class MockAuthSessionsController < Devise::SessionsController
    def create
      if mock_auth_session_params[:email] == Rails.configuration.x.omniauth_entraid.mock_username &&
          mock_auth_session_params[:password] == Rails.configuration.x.omniauth_entraid.mock_password
        @provider = Provider.from_omniauth(auth_data)
        flash[:notice] = I18n.t "devise.sessions.signed_in"
        sign_in_and_redirect @provider, event: :authentication
      else
        flash[:notice] = I18n.t("devise.failure.invalid", authentication_keys: "email")
        render :new
      end
    end

  protected

    def mock_auth_session_params
      params.expect(provider: %i[email password])
    end

    # TODO: we could potentially use a hash of auth data then call auth_data[mock_auth_session_params[:email]] to
    # allow for multiple different mock users/providers here.
    def auth_data
      OmniAuth::Strategies::Silas.mock_auth
    end

    def after_sign_in_path_for(_resource)
      providers_select_office_path
    end
  end
end
