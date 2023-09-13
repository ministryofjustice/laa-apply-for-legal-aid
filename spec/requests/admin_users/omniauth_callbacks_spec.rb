require "rails_helper"

RSpec.describe "admin users omniauth call back" do
  around do |example|
    OmniAuth.config.test_mode = true
    example.run
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    OmniAuth.config.test_mode = false
  end

  let(:token) { SecureRandom.uuid }
  let(:expires_at) { 1.hour.from_now.round }
  let(:google_expires_at) { expires_at.to_i }
  let!(:admin_user) { create(:admin_user) }
  let(:email) { admin_user.email }
  let(:target_url) { admin_settings_url }

  before do
    OmniAuth.config.add_mock(
      :google_oauth2,
      info: { email: },
      origin: target_url,
    )
  end

  describe "GET /auth/google_oauth2/callback" do
    subject(:get_request) do
      get admin_user_google_oauth2_omniauth_callback_path
    end

    it "redirects to admin user root" do
      expect(get_request).to redirect_to(admin_root_path)
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
        expect(response.body).to include("You do not have an Admin account")
      end
    end
  end
end
