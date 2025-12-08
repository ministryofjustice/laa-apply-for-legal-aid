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
    )

    example.run

    OmniAuth.config.mock_auth[:admin_entra_id] = nil
    OmniAuth.config.test_mode = false
  end

  describe "GET /auth/admin_entra_id/callback" do
    subject(:get_request) do
      get admin_user_entra_omniauth_callback_path, env: { "omniauth.origin" => target_url }
    end

    it "redirects to the target URL when it is safe" do
      expect(get_request).to redirect_to(target_url)
      follow_redirect!
      expect(response.body).to include("Successfully authenticated from entra account.")
    end

    context "when origin is an external URL" do
      let(:target_url) { "https://statics.teams.cdn.office.net/" }

      it "successfully redirects to admin root instead of external URL" do
        expect(get_request).to redirect_to(admin_root_path)
        follow_redirect!
        expect(response.body).to include("Successfully authenticated from entra account.")
      end
    end

    context "when origin is a relative path" do
      let(:target_url) { "/admin/ccms_queues" }

      it "redirects to the relative path" do
        expect(get_request).to redirect_to(target_url)
        follow_redirect!
        expect(response.body).to include("Successfully authenticated from entra account.")
      end
    end

    context "when origin is an invalid URI" do
      let(:target_url) { "http://invalid url with spaces" }

      it "redirects to admin root instead" do
        expect(get_request).to redirect_to(admin_root_path)
        follow_redirect!
        expect(response.body).to include("Successfully authenticated from entra account.")
      end
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
