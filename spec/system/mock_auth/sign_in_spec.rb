require "system_helper"
require Rails.root.join("db/seeds/test_provider_populator")

RSpec.describe "The mock entra path works as expected" do
  feature "When I click the sign in link, from the landing page, I see the confirm office list" do
    before do
      allow(Rails.configuration.x.omniauth_entraid).to receive(:mock_auth).and_return(true)
      TestProviderPopulator.call("MARTIN.RONAN@DAVIDGRAY.CO.UK")
    end

    scenario "I can complete the task list's Check your answers item" do
      visit "/"
      click_link "Sign in"
      expect(page).to have_css("h1", text: "Select the account number of the office handling this application")
    end
  end
end
