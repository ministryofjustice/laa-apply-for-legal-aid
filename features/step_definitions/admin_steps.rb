Given(/^I am logged in as an admin$/) do
  admin_user = create(:admin_user, username: "apply_maintenance", email: Faker::Internet.email)

  OmniAuth.config.test_mode = true

  OmniAuth.config.add_mock(
    :admin_entra_id,
    info: { email: admin_user.email },
    origin: admin_settings_url,
  )
  visit admin_root_path
end

Given("an application has been submitted") do
  @legal_aid_application = create(
    :application,
    :at_assessment_submitted,
    provider: create(:provider),
  )
end

Given("multiple applications have been submitted") do
  create_list(
    :application,
    15,
    :at_assessment_submitted,
    :with_applicant,
    provider: create(:provider),
  )
end

Given(/^I visit the admin page$/) do
  visit admin_path
end

Then(/^I should (see|not see) the (\S*) application$/) do |visibility, number|
  first_ref = LegalAidApplication.order(:created_at).send(number).application_ref
  if visibility == "see"
    expect(page).to have_content(first_ref)
  else
    expect(page).to have_no_content(first_ref)
  end
end

When(/^I search for the (\S*) (\S*)$/) do |number, field|
  value = LegalAidApplication.order(:created_at).send(number).send(field)
  fill_in("search", with: value)
end

When(/^I search for the (\S*) applications client$/) do |number|
  name = LegalAidApplication.order(:created_at).send(number).applicant.full_name
  fill_in("search", with: name)
end
