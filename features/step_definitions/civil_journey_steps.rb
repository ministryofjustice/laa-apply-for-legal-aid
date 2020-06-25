# features/step_definitions/civil_application_journey.feature

Given(/^I am logged in as a provider$/) do
  @registered_provider = create(:provider, username: 'test_provider')
  login_as @registered_provider
  firm = @registered_provider.firm
  @registered_provider.offices << create(:office, firm: firm, code: 'London')
  @registered_provider.offices << create(:office, firm: firm, code: 'Manchester')
end

Given(/^I visit the application service$/) do
  visit providers_root_path
end

Given('I visit the select office page') do
  visit providers_select_office_path
end

Given('I visit the confirm office page') do
  visit providers_confirm_office_path
end

Given('I have an existing office') do
  office = @registered_provider.firm.offices.find_by(code: 'London')
  @registered_provider.update!(selected_office: office)
end

Given(/^I visit the applications page$/) do
  visit providers_legal_aid_applications_path
end

Given('I previously created a passported application and left on the {string} page') do |provider_step|
  @legal_aid_application = create(
    :application,
    :with_everything,
    provider: create(:provider),
    state: :initiated,
    provider_step: provider_step.downcase
  )
  login_as @legal_aid_application.provider
end

Given('I previously created a passported application with no assets and left on the {string} page') do |provider_step|
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :without_own_home,
    :with_no_other_assets,
    :checking_passported_answers,
    provider: create(:provider),
    provider_step: provider_step.downcase
  )
  login_as @legal_aid_application.provider
end

Given(/^I view the previously created application$/) do
  find(:xpath, "//tr[contains(.,'#{@legal_aid_application.application_ref}')]/td/a").click
end

Given(/^I view the first application in the table$/) do
  find(:xpath, '//tr/td/a').click
end

Given('I start the journey as far as the applicant page') do
  steps %(
    Given I am logged in as a provider
    Given I visit the application service
    And I click link "Start"
    And I click link "Start now"
    Then I should be on the 'providers/declaration' page showing 'Declaration'
    When I click 'Agree and continue'
    Then I should be on the Applicant page
  )
end

Given('I start a non-passported application') do
  steps %(
   Given I start the journey as far as the applicant page
    Then I enter name 'Test', 'Paul'
    Then I enter the date of birth '10-12-1961'
    Then I enter national insurance number 'JA293483B'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'SW1A 1AA'
    Then I click find address
    Then I select an address 'Buckingham Palace, London, SW1A 1AA'
    Then I click 'Save and continue'
    Then I search for proceeding 'Non-molestation order'
    Then proceeding suggestions has results
    Then I select a proceeding type and continue
    Then I should be on a page showing 'Have you used delegated functions?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"
    Then I should be on a page showing "Covered under a substantive certificate"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    Then I click 'Save and continue'
    Then I should be on a page showing "We need to check your client's financial eligibility"
  )
end

Given('I start the journey as far as the client completed means page') do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_everything,
    :with_vehicle,
    :provider_assessing_means
  )
  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_client_completed_means_path(@legal_aid_application))
end

Given("I am checking the applicant's means answers") do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_everything,
    :with_vehicle,
    :provider_assessing_means
  )
  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_means_summary_path(@legal_aid_application))
end

Given('I start the merits application') do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_proceeding_types,
    :provider_assessing_means
  )
  login_as @legal_aid_application.provider
  visit Flow::KeyPoint.path_for(
    journey: :providers,
    key_point: :start_after_applicant_completes_means,
    legal_aid_application: @legal_aid_application
  )
end

Given('I start the merits application with brank transactions with no transaction type category') do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_proceeding_types,
    :provider_assessing_means,
    :with_uncategorised_credit_transactions,
    :with_uncategorised_debit_transactions
  )

  login_as @legal_aid_application.provider
  visit Flow::KeyPoint.path_for(
    journey: :providers,
    key_point: :start_after_applicant_completes_means,
    legal_aid_application: @legal_aid_application
  )
end

Given('I start the merits application and the applicant has uploaded transaction data') do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_proceeding_types,
    :provider_assessing_means,
    :with_transaction_period,
    :with_benefits_transactions
  )
  login_as @legal_aid_application.provider
  visit Flow::KeyPoint.path_for(
    journey: :providers,
    key_point: :start_after_applicant_completes_means,
    legal_aid_application: @legal_aid_application
  )
end

Given('I start the journey as far as the start of the vehicle section') do
  @legal_aid_application = create(:application)
  login_as @legal_aid_application.provider
  visit Flow::KeyPoint.path_for(
    journey: :providers,
    key_point: :start_vehicle_journey,
    legal_aid_application: @legal_aid_application
  )
end

Given('I used delegated functions') do
  @legal_aid_application.update!(used_delegated_functions: true)
end

Given('I complete the journey as far as check your answers') do
  applicant = create(
    :applicant,
    first_name: 'Test',
    last_name: 'User',
    national_insurance_number: 'CB987654A',
    date_of_birth: '03-04-1999'
  )
  create(
    :address,
    address_line_one: '3',
    address_line_two: 'LONSDALE ROAD',
    city: 'BEXLEYHEATH',
    postcode: 'DA7 4NG',
    lookup_used: true,
    applicant: applicant
  )
  proceeding_type = ProceedingType.all.sample
  @legal_aid_application = create(
    :legal_aid_application,
    :at_entering_applicant_details,
    applicant: applicant,
    proceeding_types: [proceeding_type],
    used_delegated_functions_on: 1.day.ago
  )
  @legal_aid_application.add_default_substantive_scope_limitation!
  @legal_aid_applicaiton.add_default_delegated_functions_scope_limitation! if @legal_aid_application.used_delegated_functions?

  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_check_provider_answers_path(@legal_aid_application))
  steps %(Then I should be on a page showing 'Check your answers')
end

Given('I complete the passported journey as far as check your answers') do
  applicant = create(
    :applicant,
    first_name: 'Test',
    last_name: 'Walker',
    national_insurance_number: 'JA293483A',
    date_of_birth: '10-01-1980',
    email: 'test@test.com'
  )
  create(
    :address,
    address_line_one: '3',
    address_line_two: 'LONSDALE ROAD',
    city: 'BEXLEYHEATH',
    postcode: 'DA7 4NG',
    lookup_used: true,
    applicant: applicant
  )
  @legal_aid_application = create(
    :legal_aid_application,
    :at_entering_applicant_details,
    :with_substantive_scope_limitation,
    applicant: applicant,
    used_delegated_functions_on: 1.day.ago
  )
  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_check_provider_answers_path(@legal_aid_application))
  steps %(Then I should be on a page showing 'Check your answers')
end

Given('I complete the passported journey as far as capital check your answers') do
  applicant = create(
    :applicant,
    first_name: 'Test',
    last_name: 'Walker',
    national_insurance_number: 'JA293483A',
    date_of_birth: '10-01-1980',
    email: 'test@test.com'
  )
  create(
    :address,
    address_line_one: '3',
    address_line_two: 'LONSDALE ROAD',
    city: 'BEXLEYHEATH',
    postcode: 'DA7 4NG',
    lookup_used: true,
    applicant: applicant
  )
  @legal_aid_application = create(
    :legal_aid_application,
    :with_everything,
    :with_proceeding_types,
    :applicant_details_checked,
    applicant: applicant
  )
  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_check_passported_answers_path(@legal_aid_application))
  steps %(Then I should be on a page showing 'Check your answers')
end

Given('I complete the application and view the check your answers page') do
  applicant = create(
    :applicant,
    first_name: 'Test',
    last_name: 'User',
    national_insurance_number: 'CB987654A',
    date_of_birth: '03-04-1999'
  )
  create(
    :address,
    address_line_one: '3',
    address_line_two: 'LONSDALE ROAD',
    city: 'BEXLEYHEATH',
    postcode: 'DA7 4NG',
    lookup_used: true,
    applicant: applicant
  )
  proceeding_type = ProceedingType.all.sample

  @legal_aid_application = create(
    :legal_aid_application,
    applicant: applicant,
    proceeding_types: [proceeding_type],
    state: :provider_submitted
  )
  @legal_aid_application.add_default_substantive_scope_limitation!
  @legal_aid_applicaiton.add_default_delegated_functions_scope_limitation! if @legal_aid_application.used_delegated_functions?
  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_check_provider_answers_path(@legal_aid_application))
end

Given('The means questions have been answered by the applicant') do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_proceeding_types,
    :provider_assessing_means,
    :with_uncategorised_debit_transactions
  )
  login_as @legal_aid_application.provider
  visit Flow::KeyPoint.path_for(
    journey: :providers,
    key_point: :start_after_applicant_completes_means,
    legal_aid_application: @legal_aid_application
  )
end

Given('Bank transactions exist') do
  bank_provider = create :bank_provider, applicant: @legal_aid_application.applicant
  bank_account = create :bank_account, bank_provider: bank_provider
  create_list :bank_transaction, 6, :credit, bank_account: bank_account
end

Then('I click on the View statements and add transactions link for {string}') do |transaction_type_name|
  within(:css, "div#list-item-#{transaction_type_name.underscore.tr(' ', '_')}") do
    click_link 'View statements and add transactions'
  end
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

And(/^I should (see|not see) ['|"](.*?)['|"]$/) do |visibility, text|
  if visibility == 'see'
    expect(page).to have_content(text)
  else
    expect(page).not_to have_content(text)
  end
end

When(/^I click clear search$/) do
  page.find('#clear-proceeding-search').click
end

Then(/^proceeding search field is empty$/) do
  expect(page).to have_field('proceeding-search-input', with: '')
end

Then(/^the results section is empty$/) do
  expect(page).to_not have_css('#proceeding-list > .proceeding-item')
end

Then(/^proceeding suggestions has results$/) do
  expect(page).to have_css('#proceeding-list > .proceeding-item')
end

Given('I click Check Your Answers Change link for {string}') do |field_name|
  field_name.downcase!
  field_name.gsub!(/\s+/, '_')
  within "#app-check-your-answers__#{field_name}" do
    click_link('Change')
  end
end

Then('I click on the add payments link for income type {string}') do |income_type|
  income_type.downcase!
  within "#income-type-#{income_type}" do
    click_link(I18n.t(".citizens.income_summary.index.select.#{income_type}"))
  end
end

Then('I click on the add payments link for outgoing type {string}') do |outgoing_type|
  outgoing_type.downcase!
  within "#list-item-#{outgoing_type}" do
    click_link(I18n.t(".citizens.outgoings_summary.index.select.#{outgoing_type}"))
  end
end

Then('the answer for {string} should be {string}') do |field_name, answer|
  field_name.downcase!
  field_name.gsub!(/\s+/, '_')
  expect(page).to have_css("#app-check-your-answers__#{field_name}")
  expect(page).to have_content(answer)
end

Then('I select a proceeding type and continue') do
  find('#proceeding-list').first(:button, 'Select and continue').click
end

Then('I select proceeding type {int}') do |index|
  find('#proceeding-list').all(:button, 'Select')[index - 1].click
end

Then('I expect to see {int} proceeding types selected') do |number|
  expect(page).to have_selector(
    '.selected-proceeding-types .selected-proceeding-type',
    count: number
  )
end

Then('I click the first {string} in selected proceeding types') do |link|
  find('.selected-proceeding-types').first(:link, link).click
end

Then(/^I see the client details page$/) do
  expect(page).to have_content("Enter your client's details")
end

Then('I should be on the Applicant page') do
  expect(page).to have_css('input#first_name')
end

Then('I enter name {string}, {string}') do |first_name, last_name|
  fill_in('first_name', with: first_name)
  fill_in('last_name', with: last_name)
end

Then(/^I enter the date of birth '(\d+-\d+-\d+)'$/) do |dob|
  day, month, year = dob.split('-')
  fill_in('date_of_birth', with: day)
  fill_in('dob_month', with: month)
  fill_in('dob_year', with: year)
end

Then('I enter the email address {string}') do |email|
  fill_in('email', with: email)
end

Then('I enter a date of birth for a {int} year old') do |number|
  date = (number.years + 1.month).ago
  fill_in('date_of_birth', with: date.day)
  fill_in('dob_month', with: date.month)
  fill_in('dob_year', with: date.year)
end

Then(/^I enter the purchase date '(\d+-\d+-\d+)'$/) do |purchase_date|
  day, month, year = purchase_date.split('-')
  fill_in('purchased_on', with: day)
  fill_in('purchased_on_month', with: month)
  fill_in('purchased_on_year', with: year)
end

Then('I enter the {string} date of {int} days ago') do |name, number|
  name.gsub!(/\s+/, '_')
  date = number.days.ago
  fill_in("#{name}_on", with: date.day)
  fill_in("#{name}_month", with: date.month)
  fill_in("#{name}_year", with: date.year)
end

Given('a {string} exists in the database') do |model|
  model.gsub!(/\s+/, '_')
  create model.to_sym
end

Then(/^I see a notice confirming an e-mail was sent to the citizen$/) do
  expect(page).to have_content('Application completed. An e-mail will be sent to the citizen.')
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

Then(/^I select the first checkbox$/) do
  page.first("input[type='checkbox']", visible: false).click
end

Then(/^I select the second checkbox$/) do
  page.find("input[type='checkbox']", visible: false)[1].click
end

Then('I am on the postcode entry page') do
  expect(page).to have_content("Enter your client's correspondence address")
end

Then('I am on the client use online banking page') do
  expect(page).to have_content('Check if you can continue using this service')
end

Then(/^I click find address$/) do
  click_button('Find address')
end

Then(/^I select an address '(.*)'$/) do |address|
  select(address, from: 'address_selection[lookup_id]')
end

Then('I am on the application confirmation page') do
  expect(page).to have_content('Application created')
end

Then('I am on the legal aid applications') do
  expect(page).to have_content('Your applications')
end

Then('I am on the Email Entry page') do
  expect(page).to have_content("Enter your client's email address")
end

Then('I am on the About the Financial Assessment page') do
  expect(page).to have_content('Give your client temporary access to the service')
end

Then('I am on the check your answers page for other assets') do
  expect(page).to have_content('Check your answers')
  expect(page).to have_content('Other assets')
end

Then('I am on the read only version of the check your answers page') do
  expect(page).to have_content('Home')
  expect(page).not_to have_css('.change-link')
end

Then(/^I click How we checked your client's benefits status$/) do
  page.find('#checked-status').click
end

# rubocop:disable Lint/Debugger
Then('show me the page') do
  save_and_open_page
end

Then('wait a bit') do
  sleep 2
end
# rubocop:enable Lint/Debugger
