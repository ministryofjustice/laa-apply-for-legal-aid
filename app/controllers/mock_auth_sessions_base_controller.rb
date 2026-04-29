class MockAuthSessionsBaseController < Devise::SessionsController
  def create
    if mock_auth_match?
      flash[:notice] = I18n.t "devise.sessions.signed_in"
      sign_in_and_redirect user, event: :authentication
    else
      flash[:notice] = I18n.t("devise.failure.invalid", authentication_keys: "email")
      render :new
    end
  end
end
