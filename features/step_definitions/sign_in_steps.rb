Given(/^I am logged in as a provider$/) do
  @registered_provider = create(:provider, username: "test_provider")
  login_as @registered_provider
  @registered_provider.office_codes = "0X395U:2N078D:A123456"
end

Given("I am logged in as a provider with username {string}") do |username|
  @registered_provider = Provider.find_or_create_by(username: username)
  login_as @registered_provider
  @registered_provider.office_codes = "0X395U:2N078D:A123456"
end

When("I fill in the mock user email and password") do
  fill_in "Email", with: Rails.configuration.x.omniauth_entraid.mock_username
  fill_in "Password", with: Rails.configuration.x.omniauth_entraid.mock_password
end
