require "rails_helper"

RSpec.describe "provider invalid schedules" do
  describe "GET providers/invalid_schedules" do
    let(:provider) { create(:provider) }

    before do
      login_as provider
      get providers_invalid_schedules_path
    end

    it "returns http success" do
      expect(response).to have_http_status(:ok)
    end

    it "has expected title" do
      expect(page).to have_css("h1", text: "You cannot use this service")
    end

    it "displays link to LAA landing page (a.k.a portal) for CCMS login" do
      expect(page).to have_link("CCMS", href: Rails.configuration.x.laa_landing_page_target_url)
    end

    it "displays link to contact online support" do
      expect(page).to have_link("contact online support", href: Rails.configuration.x.online_support)
    end
  end
end
