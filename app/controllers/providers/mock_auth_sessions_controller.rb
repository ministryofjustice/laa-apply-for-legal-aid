module Providers
  class MockAuthSessionsController < MockAuthSessionsBaseController
  protected

    def mock_username
      Rails.configuration.x.omniauth_entraid.mock_username
    end

    def mock_password
      Rails.configuration.x.omniauth_entraid.mock_password
    end

    def mock_auth_session_params
      params.expect(provider: %i[email password])
    end

    def user
      @user = Provider.from_omniauth(auth_data)
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
