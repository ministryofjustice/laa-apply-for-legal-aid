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

Given(/^I visit the admin applications page$/) do
  visit admin_legal_aid_applications_path
end
