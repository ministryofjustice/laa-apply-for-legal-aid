require "rails_helper"

RSpec.describe "admin users omniauth call back" do
  let!(:admin_user) { create(:admin_user, email: Faker::Internet.email) }
  let(:email) { admin_user.email }
  let(:target_url) { admin_settings_url }

  around do |example|
    OmniAuth.config.test_mode = true

    OmniAuth.config.add_mock(
      :admin_entra_id,
      info: { email: },
      origin: target_url,
    )

    example.run

    OmniAuth.config.mock_auth[:admin_entra_id] = nil
    OmniAuth.config.test_mode = false
  end

  describe "GET /auth/admin_entra_id/callback" do
    subject(:get_request) do
      get admin_user_entra_omniauth_callback_path
    end

    it "redirects to admin user root" do
      expect(get_request).to redirect_to(admin_root_path)
      follow_redirect!
      expect(response.body).to include("Successfully authenticated from entra account.")
    end

    context "with unknown email" do
      let(:email) { Faker::Internet.email }

      it "redirects to error page" do
        get_request
        expect(response).to redirect_to(error_path(:access_denied))
      end

      it "displays failure information" do
        get_request
        follow_redirect!
        expect(response.body).to include("Could not authorise you! Ask an admin for access.")
      end
    end
  end
end
