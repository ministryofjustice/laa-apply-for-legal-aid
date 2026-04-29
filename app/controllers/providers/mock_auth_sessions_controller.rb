module Providers
  class MockAuthSessionsController < MockAuthSessionsBaseController
  protected

    def mock_username
      Rails.configuration.x.omniauth_entraid.mock_username
    end

    def mock_password
      Rails.configuration.x.omniauth_entraid.mock_password
    end

    def mock_array
      Rails.configuration.x.omniauth_entraid.mock_array
    end

    def mock_auth_match?
      (mock_auth_session_params[:email] == mock_username && mock_auth_session_params[:password] == mock_password) ||
        (mock_array.present? && mock_auth_hash[mock_auth_session_params[:email]] == mock_auth_session_params[:password])
    end

    def mock_auth_hash
      @mock_auth_hash ||= mock_array.split(",").each_with_object({}) { |item, hash| hash[item.split(":")[0]] = item.split(":")[1] }
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
      base_auth = OmniAuth::Strategies::Silas.mock_auth
      if base_auth["info"]["email"] != mock_auth_session_params["email"]
        replacements = {
          info: {
            email: mock_auth_session_params["email"],
            first_name: "Test",
            last_name: "User",
          },
        }
        base_auth.merge!(replacements)
      end
      base_auth
    end

    def after_sign_in_path_for(_resource)
      providers_select_office_path
    end
  end
end
