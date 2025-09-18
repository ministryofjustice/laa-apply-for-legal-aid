require "rails_helper"

RSpec.describe AdminUsers::SessionsController do
  describe "GET admin_users/sessions#new" do
    subject(:get_session) { get new_admin_user_session_path }

    before do
      allow(Rails.configuration.x.admin_portal).to receive(:show_form).and_return(true)
    end

    it "renders successfully" do
      get_session
      expect(response).to have_http_status(:ok)
    end

    it "shows login form" do
      get_session
      expect(unescaped_response_body).to include("admin_user_username")
    end

    context "when in production environment" do
      before do
        allow(Rails.configuration.x.admin_portal).to receive(:show_form).and_return(false)
      end

      it "does not show login form" do
        get_session
        expect(unescaped_response_body).not_to include("admin_user_username")
      end

      it "shows google login" do
        get_session
        expect(unescaped_response_body).to include("Log in via entra")
      end
    end
  end
end
