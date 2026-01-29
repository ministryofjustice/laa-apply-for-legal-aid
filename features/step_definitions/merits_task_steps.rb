Given("I previously created a passported application with multiple_proceedings and left on the {string} page") do |provider_step|
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
    provider_step: provider_step.downcase,
  )
  login_as @legal_aid_application.provider
end

Then(/I should be on the (.*?) page with (.*?) regex/) do |view_name, text|
  expect(page).to have_current_path(/#{view_name}/)
  expect(page).to have_content(/#{text}/)
end

Then(/^I should (see|not see) regex (.*?)$/) do |visible, text|
  if visible.eql?("see")
    expect(page).to have_content(/#{text}/)
  else
    expect(page).to have_no_content(/#{text}/)
  end
end

When("I search for organisation {string}") do |search_terms|
  stub_organisation_search_for(search_terms)

  fill_in("organisation-search-input", with: search_terms)
end

Then("the organisation result list on page returns a {string} message") do |string|
  expect(page).to have_css(".no-organisation-items", text: string, visible: :visible)
end

# NOTE: this step does not work unless put after the step "the organisation suggestions include {string}" :(
Then(/^organisation suggestions has (\d+) results?$/) do |count|
  expect(page).to have_css(".organisation-item", visible: :visible, count:)
end

Then("organisation search field is empty") do
  expect(page).to have_field("organisation-search-input", with: "")
end

Then("organisation search field is not visible") do
  expect(page).to have_field("organisation-search-input", visible: :hidden)
end

When("the organisation suggestions include {string}") do |string|
  within("#organisation-list") do
    expect(page).to have_content(/#{string}/m)
  end
end

Then(/^I can see the highlighted search term "(.*)" (\d+) times?$/) do |string, count|
  expect(page).to have_css("mark", visible: :visible, text: string, count:)
end

Then("I select an organisation type {string} from the list") do |text|
  select(text, from: "application-merits-task-opponent-organisation-type-ccms-code-field")
end
