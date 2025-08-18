Given(/^I am logged in as a provider$/) do
  @registered_provider = create_provider_with_firm_and_office

  login_as @registered_provider
end

Given("I am logged in as a provider with username {string}") do |username|
  @registered_provider = create_provider_with_firm_and_office(username)

  login_as @registered_provider
end

When("I fill in the mock user email and password") do
  fill_in "Email", with: Rails.configuration.x.omniauth_entraid.mock_username
  fill_in "Password", with: Rails.configuration.x.omniauth_entraid.mock_password
end

# NOTE: this fakes the result of authentication office_codes and office selection
# to avoid the need to fully stub AuthN and PDA responses.
def create_provider_with_firm_and_office(username = nil)
  username ||= "test_provider"

  firm = create(:firm, ccms_id: 77_777, name: "Test firm")
  office = create(:office, ccms_id: 66_666, code: "0X395U")

  create(:provider,
         username:,
         firm:,
         office_codes: "0X395U:2N078D:A123456",
         offices: [office],
         selected_office: office)
end
