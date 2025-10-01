Given(/^I am logged in as a provider$/) do
  @registered_provider = create_provider_with_firm_and_office

  login_as @registered_provider
end

Given("I am logged in as a provider with silas_id {string}") do |silas_id|
  @registered_provider = create_provider_with_firm_and_office(silas_id)

  login_as @registered_provider
end

Given("I am logged in as a provider but have never selected an office") do
  @registered_provider = create_provider_with_firm_and_office
  @registered_provider.update!(offices: [], selected_office: nil, ccms_contact_id: nil, username: nil)

  login_as @registered_provider
end

When("I fill in the mock user email and password") do
  fill_in "Email", with: Rails.configuration.x.omniauth_entraid.mock_username
  fill_in "Password", with: Rails.configuration.x.omniauth_entraid.mock_password
end

When("I fill in the mock admin email and password") do
  fill_in "Email", with: Rails.configuration.x.admin_omniauth.mock_username
  fill_in "Password", with: Rails.configuration.x.admin_omniauth.mock_password
end

Given("there is an admin user") do
  create(:admin_user, email: Rails.configuration.x.admin_omniauth.mock_username, username: "Test user")
end

# NOTE: this fakes the result of authentication office_codes and office selection
# to avoid the need to fully stub AuthN and PDA responses.
# It performs a custom find or create by to avoid clashing with stubbed user martin ronan.
#
def create_provider_with_firm_and_office(silas_id = nil)
  silas_id ||= "51cdbbb4-75d2-48d0-aaac-fa67f013c50a"

  firm = create(:firm, ccms_id: 77_777, name: "Test firm")
  office = create(:office, ccms_id: 66_666, code: "0X395U")

  attributes = {
    silas_id:,
    firm:,
    office_codes: "0X395U:2N078D:A123456",
    offices: [office],
    selected_office: office,
  }

  provider = Provider.find_by(silas_id:)

  if provider
    provider.update!(attributes)
  else
    provider = create(:provider, attributes)
  end

  provider
end
