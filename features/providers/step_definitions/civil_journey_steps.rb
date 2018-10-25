# features/step_definitions/civil_application_journey.feature

Given(/^I visit the application service$/) do
  visit providers_root_path
end

When(/^the search for (.*) is not successful$/) do |proceeding_search|
  fill_in('proceeding-search-input', with: proceeding_search)
end

Then('the result list on page returns a {string} message') do |string|
  page.should have_content(string)
end

And(/^I search for proceeding '(.*)'$/) do |proceeding_search|
  fill_in('proceeding-search-input', with: proceeding_search)
end

When(/^I click clear search$/) do
  page.find('#clearSearch').click
end

Then(/^proceeding search field is empty$/) do
  page.should have_field('proceeding-search-input', with: '')
end

Then(/^the results section is empty$/) do
  page.should_not have_css('#proceeding-list > .proceeding-item')
end

Then(/^proceeding suggestions has results$/) do
  page.should have_css('#proceeding-list > .proceeding-item')
end

And(/^I click "([^"]*)"$/) do |button_name|
  click_button(button_name)
end

And(/^I click link "([^"]*)"$/) do |link_name|
  click_link(link_name)
end

Then(/^I select and continue$/) do
  find('#proceeding-list').first(:link, 'Select and continue').click
end

Then(/^I see the client details page$/) do
  page.should have_content("Enter your client's details")
end

Then(/^I enter name '(.*)', '(.*)'$/) do |first_name, last_name|
  fill_in('first_name', with: first_name)
  fill_in('last_name', with: last_name)
end

Then(/^I enter the date of birth '(.*)'$/) do |dob|
  dob_day, dob_month, dob_year = dob.split('-')
  fill_in('dob', with: dob_day, name: 'client_detail[dob_day]')
  fill_in('dob', with: dob_month, name: 'client_detail[dob_month]')
  fill_in('dob', with: dob_year, name: 'client_detail[dob_year]')
end

Then(/^I enter national insurance number '(.*)'$/) do |nino|
  fill_in('national_insurance_number', with: nino)
end

Then(/^I see coming soon page$/) do
  page.should have_content('Coming soon')
end

When(/^I click continue$/) do
  click_button('Continue')
end

Then(/^I enter a valid email address '(.*)'$/) do |email_address|
  fill_in('email_address', with: email_address)
end

Then(/^I enter address line one '(.*)'$/) do |address_line_one|
  fill_in('line_one', with: address_line_one)
end

Then(/^I enter city '(.*)'$/) do |city|
  fill_in('city', with: city)
end

Then(/^I enter postcode '(.*)'$/) do |postcode|
  fill_in('postcode', with: postcode)
end

Then('I am on the postcode entry page') do
  page.should have_content("Enter your client's home address")
end

Then(/^I enter a valid postcode '(.*)'$/) do |postcode|
  fill_in('postcode', with: postcode)
end

Then(/^I click find address$/) do
  click_button('Find address')
end

Then(/^I select an address '(.*)'$/) do |address|
  select(address, from: 'address_selection[address]')
end
