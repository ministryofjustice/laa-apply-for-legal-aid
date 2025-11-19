require "system_helper"
require Rails.root.join("db/seeds/test_provider_populator")

# NOTE: this uses the mocked auth enabled flow (manual login) because use of the mocked oAuth flow
# causes transparent reauthentication and therefore forced reauthentication is not testable using it.
# In real life the SiLAS authentication would have expired (12 hours after SiLAS sign in), leading to our users
# session death requiring a fresh EntraId/SiLAS sign in. This would be hard or impossible to emulate
# here so we use mock auth to exercise the `reauthable` hooks module, as a minimun.
#
RSpec.describe "The sign in lifespan and timeout works" do
  before do
    stub_provider_user_for("51cdbbb4-75d2-48d0-aaac-fa67f013c50a")
    allow(Rails.configuration.x.omniauth_entraid).to receive(:mock_auth_enabled).and_return(true)
    Rails.application.reload_routes!
  end

  let(:provider_email) { "martin.ronan@example.com" }

  after do
    allow(Rails.configuration.x.omniauth_entraid).to receive(:mock_auth_enabled).and_call_original
    Rails.application.reload_routes!
  end

  feature "with idle timeouts disabled and business hours extended" do
    before do
      allow(Provider).to receive(:timeout_in).and_return(99_999.minutes) # stub/disable idle timeout
    end

    after do
      allow(Provider).to receive(:timeout_in).and_call_original # unstub idle timeout
    end

    scenario "I am signed out if session lifespan of 12 hours is exceeded" do
      travel_to Time.zone.local(2025, 11, 4, 7, 30)

      visit "/"
      click_on(class: "govuk-button", text: "Sign in")
      fill_in "Email", with: Rails.configuration.x.omniauth_entraid.mock_username
      fill_in "Password", with: Rails.configuration.x.omniauth_entraid.mock_password

      click_on(class: "govuk-button", text: "Sign in")
      expect(page).to have_css("h1", text: "Select the account number of the office handling this application")
      click_on(provider_email)
      expect(page).to have_css("h1", text: "Your profile")

      travel_to Time.zone.local(2025, 11, 4, 19, 31)

      click_on(provider_email)
      expect(page).to have_css("h1", text: "Sign in")
    end

    scenario "I am NOT signed out if session lifespan is NOT exceeded" do
      travel_to Time.zone.local(2025, 11, 4, 7, 30)

      visit "/"
      click_on(class: "govuk-button", text: "Sign in")
      fill_in "Email", with: Rails.configuration.x.omniauth_entraid.mock_username
      fill_in "Password", with: Rails.configuration.x.omniauth_entraid.mock_password

      click_on(class: "govuk-button", text: "Sign in")
      expect(page).to have_css("h1", text: "Select the account number of the office handling this application")
      click_on(provider_email)
      expect(page).to have_css("h1", text: "Your profile")

      travel_to Time.zone.local(2025, 11, 4, 19, 30)

      click_on(provider_email)
      expect(page).to have_css("h1", text: "Your profile")
    end
  end

  feature "with idle timeouts enabled" do
    scenario "I am signed out if session idle timeout of 1 hour is exceeded" do
      travel_to Time.zone.local(2025, 11, 4, 7, 30)

      visit "/"
      click_on(class: "govuk-button", text: "Sign in")
      fill_in "Email", with: Rails.configuration.x.omniauth_entraid.mock_username
      fill_in "Password", with: Rails.configuration.x.omniauth_entraid.mock_password

      click_on(class: "govuk-button", text: "Sign in")
      expect(page).to have_css("h1", text: "Select the account number of the office handling this application")
      click_on(provider_email)
      expect(page).to have_css("h1", text: "Your profile")

      travel_to Time.zone.local(2025, 11, 4, 8, 30)

      click_on(provider_email)
      expect(page).to have_css("h1", text: "Sign in")
    end

    scenario "I am NOT signed out if session idle timout of 1 hour is NOT exceeded" do
      travel_to Time.zone.local(2025, 11, 4, 7, 30)

      visit "/"
      click_on(class: "govuk-button", text: "Sign in")
      fill_in "Email", with: Rails.configuration.x.omniauth_entraid.mock_username
      fill_in "Password", with: Rails.configuration.x.omniauth_entraid.mock_password

      click_on(class: "govuk-button", text: "Sign in")
      expect(page).to have_css("h1", text: "Select the account number of the office handling this application")
      click_on(provider_email)
      expect(page).to have_css("h1", text: "Your profile")

      travel_to Time.zone.local(2025, 11, 4, 8, 29)

      click_on(provider_email)
      expect(page).to have_css("h1", text: "Your profile")
    end
  end
end
