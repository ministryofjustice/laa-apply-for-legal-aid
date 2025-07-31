require "rails_helper"

RSpec.describe Providers::OmniauthCallbacksController do
  describe "GET /auth/entra_id/callback" do
    subject(:get_request) do
      get provider_entra_id_omniauth_callback_path
    end

    it "redirects to provider confirm_office path" do
      expect(get_request).to redirect_to(providers_confirm_office_path)
    end

    context "when the user is unknown" do
      before do
        OmniAuth.config.mock_auth[:entra_id] = nil
      end

      it "redirects to error page" do
        expect(get_request).to redirect_to(root_path)
      end

      it "displays failure information" do
        get_request
        follow_redirect!
        expect(response.body).to include("Could not authorise you! Ask an admin for access")
      end
    end
  end
end
