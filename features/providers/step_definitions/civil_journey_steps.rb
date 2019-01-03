# features/step_definitions/civil_application_journey.feature

Given(/^I visit the application service$/) do
  visit providers_root_path
end

Given('I start the journey as far as the applicant page') do
  steps %(
    Given I visit the application service
    And I click link "Start"
    And I click "Start now"
    And I search for proceeding 'Application for a care order'
    Then proceeding suggestions has results
    Then I select and continue
    Then I should be on the Applicant page
  )
end

Given('I complete the journey as far as check your answers') do
  steps %(
    Given I start the journey as far as the applicant page
    Then I enter name 'Test', 'User'
    Then I enter the date of birth '03-04-1999'
    Then I enter national insurance number 'CB987654A'
    Then I enter an email address 'test@test.com'
    Then I click "Continue"
    Then I am on the postcode entry page
    Then I enter a postcode 'DA74NG'
    Then I click find address
    Then I select an address '3, LONSDALE ROAD, BEXLEYHEATH, DA7 4NG'
    Then I click "Continue"
    Then I should be on the Check Your Answers page
  )
end

When('the search for {string} is not successful') do |proceeding_search|
  fill_in('proceeding-search-input', with: proceeding_search)
end

Then('the result list on page returns a {string} message') do |string|
  expect(page).to have_content(string)
end

And('I search for proceeding {string}') do |proceeding_search|
  fill_in('proceeding-search-input', with: proceeding_search)
  wait_for_ajax
end

When(/^I click clear search$/) do
  page.find('#clear-proceeding-search').click
end

Then(/^proceeding search field is empty$/) do
  puts ">>>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<"
  expect(page).to have_field('proceeding-search-input', with: '')
  puts ">>>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<"
end

Then(/^the results section is empty$/) do
  expect(page).to_not have_css('#proceeding-list > .proceeding-item')
end

Then(/^proceeding suggestions has results$/) do
  expect(page).to have_css('#proceeding-list > .proceeding-item')
end

And('I click {string}') do |button_name|
  click_button(button_name)
end

Given('I click link {string}') do |link_name|
  click_link(link_name)
end

Given('I click Check Your Answers Change link for {string}') do |field_name|
  field_name.downcase!
  field_name.gsub!(/\s+/, '_')
  within "#app-check-your-answers__#{field_name}" do
    click_link('Change')
  end
end

Then('the answer for {string} should be {string}') do |field_name, answer|
  field_name.downcase!
  field_name.gsub!(/\s+/, '_')
  within "#app-check-your-answers__#{field_name} .app-check-your-answers__answer" do
    have_content(answer)
  end
end

Then(/^I select and continue$/) do
  find('#proceeding-list').first(:button, 'Select and continue').click
end

Then(/^I see the client details page$/) do
  expect(page).to have_content("Enter your client's details")
end

Then('I should be on the Applicant page') do
  expect(page).to have_css('input#first_name')
end

Then('I should be on the Check Your Answers page') do
  expect(page).to have_content('Check your answers')
end

Then('I enter name {string}, {string}') do |first_name, last_name|
  fill_in('first_name', with: first_name)
  fill_in('last_name', with: last_name)
end

Then(/^I enter the date of birth '(\d+-\d+-\d+)'$/) do |dob|
  dob_day, dob_month, dob_year = dob.split('-')
  fill_in('dob_day', with: dob_day)
  fill_in('dob_month', with: dob_month)
  fill_in('dob_year', with: dob_year)
end

Then(/^I see a notice confirming an e-mail was sent to the citizen$/) do
  expect(page).to have_content('Application completed. An e-mail will be sent to the citizen.')
end

Then('I enter an email address {string}') do |email_address|
  fill_in('email', with: email_address)
end

Then('I choose {string}') do |option|
  choose(option, allow_label_click: true)
end

# Matches:
#   Then I enter a field name 'entry'
#   Then I enter the field name "entry"
#   Then I enter field name 'entry'
Then(/^I enter ((a|an|the)\s)?([\w\s]+?) ["']([\w\s]+)["']$/) do |_ignore, field_name, entry|
  field_name.downcase!
  field_name.gsub!(/\s+/, '_')
  fill_in(field_name, with: entry)
end

Then('I am on the postcode entry page') do
  expect(page).to have_content("Enter your client's home address")
end

Then('I am on the benefit check results page') do
  expect(page).to have_content("Your client's tax and benefits status")
end

Then('I am on the client use online banking page') do
  expect(page).to have_content('Does your client use online banking?')
end

Then(/^I click find address$/) do
  click_button('Find address')
end

Then(/^I select an address '(.*)'$/) do |address|
  select(address, from: 'address_selection[lookup_id]')
end

Then(/^I see a notice saying that the citizen receives benefits$/) do
  expect(page).to have_content('Your client receives benefits that qualify for legal aid.')
end

Then(/^I see a notice saying that the citizen does not receive benefits$/) do
  expect(page).to have_content('Your client does not receive benefits that qualify for legal aid.')
end

Then('I am on the application confirmation page') do
  expect(page).to have_content('Application created')
end

Then('I am on the legal aid applications') do
  expect(page).to have_content('Your legal aid applications')
end

Then('I am on the About the Financial Assessment page') do
  expect(page).to have_content('About the online financial assessment')
end
