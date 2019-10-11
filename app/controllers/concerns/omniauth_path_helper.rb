module OmniauthPathHelper
  def omniauth_login_start_path(type)
    "/auth/#{type}"
  end
end
