require "system_helper"
require Rails.root.join("db/seeds/test_provider_populator")

RSpec.describe "The mock entra path works as expected" do
  feature "When I click the sign in link, from the landing page, I see the select office list" do
    before do
      OmniAuth::Strategies::Silas.mock_auth
    end

    scenario "I can see the select office choice list" do
      visit "/"
      click_link "Sign in"
      expect(page).to have_css("h1", text: "Select the account number of the office handling this application")
    end
  end
end
