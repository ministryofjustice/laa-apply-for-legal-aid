require "rails_helper"

RSpec.describe "provider omniauth call back" do
  before do
    allow(AlertManager).to receive(:capture_message) # optional, to prevent real error logging
  end

  describe "GET /auth/entra_id/callback" do
    subject(:get_request) do
      get provider_entra_id_omniauth_callback_path
    end

    around do |example|
      OmniAuth.config.test_mode = true
      OmniAuth::Strategies::Silas.mock_auth

      example.run

      OmniAuth.config.mock_auth[:entra_id] = nil
      OmniAuth.config.test_mode = false
    end

    context "when the provider is known and authorised" do
      it "signs in the provider and redirects to select office path" do
        expect(get_request).to redirect_to(providers_select_office_path)
      end

      it "displays sign in success message" do
        get_request
        follow_redirect!
        expect(response.body).to include("Signed in successfully")
      end
    end

    context "when the provider is unknown" do
      before do
        OmniAuth.config.mock_auth[:entra_id] = nil
      end

      it "redirects to root path" do
        expect(get_request).to redirect_to(root_path)
      end

      it "displays sign in failure message" do
        get_request
        follow_redirect!
        expect(response.body).to include("Could not authorise you! Ask an admin for access")
      end
    end

    context "when the provider's credentials are invalid" do
      before do
        OmniAuth.config.mock_auth[:entra_id] = :invalid_credentials
      end

      it "redirects to the custom failure page" do
        get_request
        expect(request).to redirect_to(a_string_starting_with("/auth/failure"))
        follow_redirect!

        expect(response).to redirect_to(error_path(:access_denied))
        follow_redirect!

        expect(page).to have_content("Access denied")
      end

      it "logs the exception" do
        expect(Rails.logger).to receive(:warn).with(/Omniauth error: /)

        get_request
      end

      it "captures the exception with AlertManager" do
        expect(AlertManager).to receive(:capture_exception)

        get_request
      end
    end
  end

  describe "GET /providers/auth/failure" do
    it "displays flash and redirects for entra_id failure" do
      get providers_auth_failure_path, params: { strategy: "entra_id", message: "invalid_credentials" }
      follow_redirect!
      expect(flash[:error]).to include("Could not authenticate you from Entra due to \"Invalid credentials\".")
    end
  end
end
