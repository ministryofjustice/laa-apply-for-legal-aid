Given('I previously created a passported application with multiple_proceedings and left on the {string} page') do |provider_step|
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :without_own_home,
    :with_multiple_proceeding_types_inc_section8,
    :with_no_other_assets,
    :with_policy_disregards,
    :with_passported_state_machine,
    :checking_passported_answers,
    provider: create(:provider),
    provider_step: provider_step.downcase
  )
  login_as @legal_aid_application.provider
end

Then(/I should be on the (.*?) page with (.*?) regex/) do |view_name, text|
  expect(page.current_path).to end_with(view_name)
  expect(page).to have_content(/#{text}/)
end

Then(/^I should (see|not see) regex (.*?)$/) do |visible, text|
  if visible.eql?('see')
    expect(page).to have_content(/#{text}/)
  else
    expect(page).to_not have_content(/#{text}/)
  end
end
