module AdminUsers
  class MockAuthSessionsController < MockAuthSessionsBaseController
  protected

    def mock_username
      Rails.configuration.x.admin_omniauth.mock_username
    end

    def mock_password
      Rails.configuration.x.admin_omniauth.mock_password
    end

    def mock_auth_session_params
      params.expect(admin_user: %i[email password])
    end

    def user
      @user = AdminUser.from_omniauth(auth_data)
    end

    def auth_data
      OmniAuth::Strategies::AdminLogin.mock_auth
    end

    def after_sign_in_path_for(_resource)
      admin_root_path
    end
  end
end
