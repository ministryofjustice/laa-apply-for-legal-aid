Given(/^I am logged in as an admin$/) do
  OmniAuth.config.test_mode = true
  admin_user = create(:admin_user, username: 'apply_maintenance')
  OmniAuth.config.add_mock(
    :google_oauth2,
    info: { email: admin_user.email },
    origin: admin_settings_url
  )
  get admin_user_google_oauth2_omniauth_callback_path
  follow_redirect!
  visit admin_legal_aid_applications_path
  click_link 'Log in via google'
end

Given('an application has been submitted') do
  @legal_aid_application = create(
    :application,
    :at_assessment_submitted,
    provider: create(:provider)
  )
end

Given('multiple applications have been submitted') do
  create_list(
    :application,
    15,
    :at_assessment_submitted,
    :with_applicant,
    provider: create(:provider)
  )
  # create :application,
  #        :with_applicant,
  #        provider: create(:provider)
  # binding.pry unless Applicant.count > 0
end

Given(/^I visit the admin applications page$/) do
  visit admin_legal_aid_applications_path
end

Then(/^I should (see|not see) the (\S*) application$/) do |visibility, number|
  first_ref = LegalAidApplication.order(:created_at).send(number).application_ref
  if visibility == 'see'
    expect(page).to have_content(first_ref)
  else
    expect(page).not_to have_content(first_ref)
  end
end

When(/^I search for the (\S*) (\S*)$/) do |number, field|
  value = LegalAidApplication.order(:created_at).send(number).send(field)
  fill_in('search', with: value)
end

When(/^I search for the (\S*) applications client$/) do |number|
  name = LegalAidApplication.order(:created_at).send(number).applicant.full_name
  fill_in('search', with: name)
end
