require "rails_helper"

RSpec.describe "provider invalid schedules" do
  describe "GET providers/user_not_founds" do
    let(:provider) { create(:provider) }

    before do
      login_as provider
      get providers_user_not_founds_path
    end

    it "returns http success" do
      expect(response).to have_http_status(:ok)
    end

    it "has expected content" do
      expect(page)
        .to have_css("h1", text: "Sorry, there was a problem getting your account information")
        .and have_content("Try again later.")
        .and have_link("Contact our support team", href: contact_path)
        .and have_link("Try again now", href: providers_select_office_path)
    end
  end
end
