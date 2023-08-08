# features/step_definitions/civil_application_journey.feature

Given(/^I am logged in as a provider$/) do
  @registered_provider = create(:provider, username: "test_provider")
  login_as @registered_provider
  firm = @registered_provider.firm
  @registered_provider.offices << create(:office, firm:, code: "London")
  @registered_provider.offices << create(:office, firm:, code: "Manchester")
end

Given(/^I visit the application service$/) do
  visit providers_root_path
end

Given("I visit the select office page") do
  visit providers_select_office_path
end

Given("I visit the confirm office page") do
  visit providers_confirm_office_path
end

When(/^I visit the root page/) do
  visit root_path
end

When(/^I submit to saml/) do
  find("input[name*=commit]").click
end

Given("I have an existing office") do
  office = @registered_provider.firm.offices.find_by(code: "London")
  @registered_provider.update!(selected_office: office)
end

Given(/^I visit the applications page$/) do
  visit providers_legal_aid_applications_path
end

Given("I have previously created multiple applications") do
  provider = create(:provider)
  create_list(:legal_aid_application, 3, :with_non_passported_state_machine, provider:)
  create_list :legal_aid_application, 3, :with_passported_state_machine, :at_assessment_submitted, provider:
  @legal_aid_application = create(
    :application,
    :with_everything,
    :with_passported_state_machine,
    :initiated,
    provider:,
  )
  login_as @legal_aid_application.provider
end

Given("I have created and submitted an application") do
  @legal_aid_application = create(
    :application,
    :with_everything,
    :with_passported_state_machine,
    :with_merits_submitted_at,
    :initiated,
    provider: create(:provider),
  )
  login_as @legal_aid_application.provider
end

Given(/^I have created an application for a (\d*?) year old$/) do |age|
  applicant = create(:applicant,
                     age_for_means_test_purposes: age,
                     date_of_birth: Time.zone.today - age.to_i.years)
  @legal_aid_application = create(
    :application,
    :with_everything,
    :with_passported_state_machine,
    :checking_merits_answers,
    :initiated,
    applicant:,
    provider: create(:provider),
    provider_step: "confirm_client_declarations",
  )
  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_confirm_client_declaration_path(@legal_aid_application))
end

Given("I have created but not submitted an application") do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :draft,
    :initiated,
    provider: create(:provider),
  )
  login_as @legal_aid_application.provider
end

Given("I previously created a passported application and left on the {string} page") do |provider_step|
  @legal_aid_application = create(
    :application,
    :with_everything,
    :with_passported_state_machine,
    :initiated,
    provider: create(:provider),
    provider_step: provider_step.downcase,
  )
  login_as @legal_aid_application.provider
end

Given("I previously created a passported application with no assets and left on the {string} page") do |provider_step|
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :without_own_home,
    :with_proceedings,
    :with_no_other_assets,
    :with_policy_disregards,
    :with_passported_state_machine,
    :checking_passported_answers,
    provider: create(:provider),
    provider_step: provider_step.downcase,
  )
  login_as @legal_aid_application.provider
end

Given("I have a passported application with no assets on the {string} page") do |provider_step|
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :without_own_home,
    :with_proceedings,
    :with_no_other_assets,
    :with_policy_disregards,
    :with_passported_state_machine,
    :provider_entering_means,
    provider: create(:provider),
    provider_step: provider_step.downcase,
    explicit_proceedings: [:da001],
    set_lead_proceeding: :da001,
  )
  create(:legal_framework_merits_task_list, :da001, legal_aid_application: @legal_aid_application)
  login_as @legal_aid_application.provider
end

Given("the setting to manually review all cases is enabled") do
  Setting.setting.update!(manually_review_all_cases: true)
end

Then("I choose a {string} radio button") do |radio_button_name|
  choose(radio_button_name, allow_label_click: true)
end

Given(/^I view the previously created application$/) do
  find(:xpath, "//tr[contains(.,'#{@legal_aid_application.application_ref}')]/td[1]/a").click
end

Then(/^I should not see the previously created application$/) do
  expect(page).not_to have_content(@legal_aid_application.applicant.full_name)
end

Given(/^I click delete for the previously created application$/) do
  find(:xpath, "//tr[contains(.,'#{@legal_aid_application.application_ref}')]/td[contains(.,'Delete')]").click
end

Given(/^I view the first application in the table$/) do
  find(:xpath, "//tr/td[1]/a").click
end

Given("I start the journey as far as the applicant page") do
  steps %(
    Given I am logged in as a provider
    Given I visit the application service
    And I click link "Start"
    And I click link "Make a new application"
    Then I should be on the 'providers/declaration' page showing 'Declaration'
    When I click 'Agree and continue'
    Then I should be on the Applicant page
  )
end

Given("I start the journey as far as the client completed means page") do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_everything,
    :with_vehicle,
    :with_non_passported_state_machine,
    :provider_assessing_means,
  )
  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_client_completed_means_path(@legal_aid_application))
end

Given("I am checking answers on the check capital answers page") do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_everything,
    :with_vehicle,
    :with_non_passported_state_machine,
    :provider_assessing_means,
  )
  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_check_capital_answers_path(@legal_aid_application))
end

Given("I am checking the applicant's means income answers") do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_everything,
    :with_non_passported_state_machine,
    :checking_means_income,
  )
  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_means_check_income_answers_path(@legal_aid_application))
end

Given("I have completed the non-passported means assessment and start the merits assessment") do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_non_passported_state_machine,
    :provider_entering_merits,
    :with_transaction_period,
    :with_policy_disregards,
    :with_benefits_transactions,
    :with_cfe_v5_result,
    :with_proceedings,
    explicit_proceedings: %i[da001],
    set_lead_proceeding: :da001,
  )

  create :legal_framework_merits_task_list, :da001, legal_aid_application: @legal_aid_application
  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_merits_task_list_path(@legal_aid_application))
end

Given("I start the means application") do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_proceedings,
    :with_non_passported_state_machine,
    :provider_assessing_means,
    :with_policy_disregards,
  )
  login_as @legal_aid_application.provider
  visit Flow::KeyPoint.path_for(
    journey: :providers,
    key_point: :start_after_applicant_completes_means,
    legal_aid_application: @legal_aid_application,
  )
end

Given("I start the merits application with bank transactions with no transaction type category") do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_proceedings,
    :with_non_passported_state_machine,
    :provider_entering_merits,
    :with_transaction_period,
    :with_uncategorised_credit_transactions,
    :with_uncategorised_debit_transactions,
  )

  create :legal_framework_merits_task_list, :da001, legal_aid_application: @legal_aid_application
  login_as @legal_aid_application.provider
  visit Flow::KeyPoint.path_for(
    journey: :providers,
    key_point: :start_after_applicant_completes_means,
    legal_aid_application: @legal_aid_application,
  )
end

Given("I start the merits application with student finance") do
  @legal_aid_application = create(
    :application,
    :with_applicant_with_student_loan,
    :with_proceedings,
    :with_non_passported_state_machine,
    :provider_assessing_means,
    :with_policy_disregards,
    :with_transaction_period,
    :with_uncategorised_credit_transactions,
  )

  login_as @legal_aid_application.provider
  visit Flow::KeyPoint.path_for(
    journey: :providers,
    key_point: :start_after_applicant_completes_means,
    legal_aid_application: @legal_aid_application,
  )
end

Given("I start the application with a negative benefit check result") do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_proceedings,
    :with_non_passported_state_machine,
    :applicant_details_checked,
    :with_negative_benefit_check_result,
  )

  login_as @legal_aid_application.provider
  visit Flow::KeyPoint.path_for(
    journey: :providers,
    key_point: :check_benefits,
    legal_aid_application: @legal_aid_application,
  )
end

Given("I start the application with a negative benefit check result and no used delegated functions") do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_proceedings,
    :with_non_passported_state_machine,
    :applicant_details_checked,
    :with_negative_benefit_check_result,
  )

  login_as @legal_aid_application.provider
  visit Flow::KeyPoint.path_for(
    journey: :providers,
    key_point: :check_benefits,
    legal_aid_application: @legal_aid_application,
  )
end

Given("I start the means application and the applicant has uploaded transaction data") do
  # These changes are to add existing categories (as would have been selected by the applicant)
  # to the application e.g. housing, benefits, the categories are now selected by the provider
  # so should not be necessary, however in practice this means that the checkboxes are not being populated
  # on the page for the transactions pages so I have made the tests pass in the current format for now.
  @applicant = create :applicant,
                      with_bank_accounts: 1

  @legal_aid_application = create(
    :application,
    :with_non_passported_state_machine,
    :provider_assessing_means,
    :with_policy_disregards,
    :with_transaction_period,
    :with_benefits_transactions,
    :with_cfe_v5_result,
    :with_proceedings,
    applicant: @applicant,
    explicit_proceedings: [:da001],
    set_lead_proceeding: :da001,
  )

  bank_account = @applicant.bank_accounts.first
  create_list :bank_transaction, 2, :credit, bank_account:, amount: rand(1...1_500.0).round(2)
  create_list :bank_transaction, 3, :debit, bank_account:,  amount: rand(1...1_500.0).round(2)
  create(:legal_framework_merits_task_list, :da001, legal_aid_application: @legal_aid_application)
  login_as @legal_aid_application.provider
  visit Flow::KeyPoint.path_for(
    journey: :providers,
    key_point: :start_after_applicant_completes_means,
    legal_aid_application: @legal_aid_application,
  )
end

Given("I start the means review journey with employment income for a single job from HMRC") do
  @legal_aid_application = create(
    :application,
    :with_employed_applicant,
    :with_proceedings,
    :with_non_passported_state_machine,
    :provider_assessing_means,
  )

  create :employment, legal_aid_application: @legal_aid_application, owner_id: @legal_aid_application.applicant.id, owner_type: "Applicant"

  login_as @legal_aid_application.provider
  visit Flow::KeyPoint.path_for(
    journey: :providers,
    key_point: :start_after_applicant_completes_means,
    legal_aid_application: @legal_aid_application,
  )
end

Given("I start the means review journey with no employment income from HMRC") do
  @legal_aid_application = create(
    :application,
    :with_proceedings,
    :with_non_passported_state_machine,
    :provider_assessing_means,
    applicant: build(:applicant, :employed),
  )

  login_as @legal_aid_application.provider
  visit Flow::KeyPoint.path_for(
    journey: :providers,
    key_point: :start_after_applicant_completes_means,
    legal_aid_application: @legal_aid_application,
  )
end

Given("I start the means review journey with employment income for multiple jobs from HMRC") do
  @legal_aid_application = create(
    :application,
    :with_employed_applicant,
    :with_proceedings,
    :with_non_passported_state_machine,
    :provider_assessing_means,
  )

  create :employment, legal_aid_application: @legal_aid_application, owner_id: @legal_aid_application.applicant.id, owner_type: "Applicant"
  create :employment, :example1_usecase1, legal_aid_application: @legal_aid_application, owner_id: @legal_aid_application.applicant.id, owner_type: "Applicant"

  login_as @legal_aid_application.provider
  visit Flow::KeyPoint.path_for(
    journey: :providers,
    key_point: :start_after_applicant_completes_means,
    legal_aid_application: @legal_aid_application,
  )
end

Given("I start the journey as far as the start of the vehicle section") do
  @legal_aid_application = create(
    :application,
    :passported,
  )
  login_as @legal_aid_application.provider
  visit Flow::KeyPoint.path_for(
    journey: :providers,
    key_point: :start_vehicle_journey,
    legal_aid_application: @legal_aid_application,
  )
end

Given(/^I view the limitations for an application with proceedings (at|below) the max threshold( with delegated_functions)?/) do |threshold, include_df|
  limit = threshold.eql?("at") ? 25_000 : 5_000
  @legal_aid_application = create :legal_aid_application, :with_applicant_and_address
  create :proceeding, :da006, legal_aid_application: @legal_aid_application, substantive_cost_limitation: limit, lead_proceeding: true, used_delegated_functions_on: nil
  create :proceeding, :se013, legal_aid_application: @legal_aid_application, substantive_cost_limitation: limit, used_delegated_functions_on: nil
  steps %(And I used delegated functions) if include_df
  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_limitations_path(@legal_aid_application))
end

Given("I have completed a non-passported application and reached the merits task_list") do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_non_passported_state_machine,
    :provider_entering_merits,
    :with_proceedings, explicit_proceedings: %i[se014 da001]
  )
  create :legal_framework_merits_task_list, legal_aid_application: @legal_aid_application
  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_merits_task_list_path(@legal_aid_application))
end

Given("I have started an application and reached the proceedings list") do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_applicant_and_address_lookup,
    :with_proceedings,
  )
  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_has_other_proceedings_path(@legal_aid_application))
  steps %(Then I should be on a page showing 'Do you want to add another proceeding?')
end

Given("I have started an application with multiple proceedings and reached the check your answers page") do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_applicant_and_address_lookup,
    :with_proceedings,
    :at_checking_applicant_details,
    :with_delegated_functions_on_proceedings,
    explicit_proceedings: %i[da001 se013],
    set_lead_proceeding: :da001,
    df_options: { DA001: [10.days.ago, 10.days.ago], SE013: nil },
    substantive_application_deadline_on: 10.days.from_now,
  )
  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_check_provider_answers_path(@legal_aid_application))
  steps %(Then I should be on a page showing 'Check your answers')
end

Given("I have started an application with multiple proceedings") do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_applicant_and_address_lookup,
    :with_proceedings,
    explicit_proceedings: %i[da001 se013],
    set_lead_proceeding: :da001,
  )
  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_has_other_proceedings_path(@legal_aid_application))
  steps %(Then I should be on a page showing 'Do you want to add another proceeding?')
end

Given("I have started an application where the client is a defendant on the domestic abuse proceeding") do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_applicant_and_address_lookup,
    :with_proceedings,
    explicit_proceedings: %i[da001 se013],
    set_lead_proceeding: :da001,
  )
  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_has_other_proceedings_path(@legal_aid_application))
  steps %(Then I should be on a page showing 'Do you want to add another proceeding?')
  proceeding = @legal_aid_application.proceedings.find_by(ccms_code: "DA001")
  proceeding.update(
    client_involvement_type_ccms_code: "D",
    client_involvement_type_description: "Defendant/respondent",
    used_delegated_functions: false,
  )
  proceeding = @legal_aid_application.proceedings.find_by(ccms_code: "SE013")
  proceeding.update(
    used_delegated_functions: false,
  )
end

And("I visit the merits question page") do
  visit(providers_legal_aid_application_merits_task_list_path(@legal_aid_application))
end

Given("I used delegated functions") do
  @legal_aid_application.proceedings.each do |proceeding|
    proceeding.update!(used_delegated_functions: true,
                       used_delegated_functions_on: Date.current,
                       used_delegated_functions_reported_on: Date.current)
    proceeding.save!
  end
end

Given("I complete the journey as far as check your answers") do
  applicant = create(
    :applicant,
    first_name: "Test",
    last_name: "User",
    date_of_birth: "03-04-1999",
    has_national_insurance_number: true,
    national_insurance_number: "CB987654A",
  )
  create(
    :address,
    address_line_one: "Transport For London",
    address_line_two: "98 Petty France",
    city: "London",
    postcode: "SW1H 9EA",
    lookup_used: true,
    applicant:,
  )
  @legal_aid_application = create(
    :legal_aid_application,
    :at_entering_applicant_details,
    :with_proceedings,
    applicant:,
  )
  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_check_provider_answers_path(@legal_aid_application))
  steps %(Then I should be on a page showing 'Check your answers')
end

Given("I complete the journey as far as check client details with multiple proceedings selected") do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_proceedings,
    :with_non_passported_state_machine,
    :at_entering_applicant_details,
    explicit_proceedings: %i[da001 da005],
    set_lead_proceeding: :da001,
  )

  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_check_provider_answers_path(@legal_aid_application))
  steps %(Then I should be on a page showing 'Check your answers')
end

Given("I complete the journey as far as check client details with a partner") do
  applicant = create(:applicant, :with_partner)
  create(
    :address,
    address_line_one: "Transport For London",
    address_line_two: "98 Petty France",
    city: "London",
    county: nil,
    postcode: "SW1H 9EA",
    lookup_used: true,
    applicant:,
  )
  partner = create(:partner)
  @legal_aid_application = create(
    :application,
    :with_proceedings,
    :with_non_passported_state_machine,
    :at_entering_applicant_details,
    applicant:,
    partner:,
  )

  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_check_provider_answers_path(@legal_aid_application))
  steps %(Then I should be on a page showing 'Check your answers')
end

Given("I complete the journey as far as the employment status page for a partner with no NI number") do
  applicant = create(:applicant, :with_partner)
  create(
    :address,
    address_line_one: "Transport For London",
    address_line_two: "98 Petty France",
    city: "London",
    county: nil,
    postcode: "SW1H 9EA",
    lookup_used: true,
    applicant:,
  )
  partner = create(:partner, :no_nino)
  @legal_aid_application = create(
    :application,
    :with_proceedings,
    :with_non_passported_state_machine,
    :at_entering_applicant_details,
    :provider_confirming_applicant_eligibility,
    applicant:,
    partner:,
  )

  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_partners_employed_index_path(@legal_aid_application))
  steps %(Then I should be on a page showing 'employment ')
end

Given("I complete the passported journey as far as check your answers for client details") do
  applicant = create(
    :applicant,
    first_name: "Test",
    last_name: "Walker",
    national_insurance_number: "JA293483A",
    date_of_birth: "10-01-1980",
    email: "test@test.com",
  )
  create(
    :address,
    address_line_one: "Transport For London",
    address_line_two: "98 Petty France",
    city: "London",
    county: nil,
    postcode: "SW1H 9EA",
    lookup_used: true,
    applicant:,
  )
  @legal_aid_application = create(
    :legal_aid_application,
    :with_passported_state_machine,
    :at_entering_applicant_details,
    :with_proceedings,
    explicit_proceedings: [:da001],
    set_lead_proceeding: :da001,
    applicant:,
  )
  create(:legal_framework_merits_task_list, :da001, legal_aid_application: @legal_aid_application)
  login_as @legal_aid_application.provider

  visit(providers_legal_aid_application_check_provider_answers_path(@legal_aid_application))

  steps %(Then I should be on a page showing 'Check your answers')
end

Given("I complete the journey as far as check passported answers with multiple proceedings") do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_proceedings,
    :with_parties_mental_capacity,
    :with_domestic_abuse_summary,
    :with_non_passported_state_machine,
    :provider_entering_merits,
    :with_transaction_period,
    :with_attached_statement_of_case,
    :with_chances_of_success,
    :with_gateway_evidence,
    :with_policy_disregards,
    :with_benefits_transactions,
    explicit_proceedings: %i[da001 da005],
    set_lead_proceeding: :da001,
  )
  create(:legal_framework_merits_task_list, :da001_da005_as_applicant, legal_aid_application: @legal_aid_application)
  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_check_merits_answers_path(@legal_aid_application))

  steps %(Then I should be on a page showing 'Check your answers')
end

Given("I complete the non-passported journey as far as check your answers") do
  applicant = create(
    :applicant,
    first_name: "Test",
    last_name: "Test",
    national_insurance_number: "JA123456A",
    date_of_birth: "01-01-1970",
    email: "test@test.com",
  )
  create(
    :address,
    address_line_one: "Transport For London",
    address_line_two: "98 Petty France",
    city: "London",
    postcode: "SW1H 9EA",
    lookup_used: true,
    applicant:,
  )
  @legal_aid_application = create(
    :legal_aid_application,
    :with_non_passported_state_machine,
    :at_entering_applicant_details,
    :with_proceedings,
    applicant:,
  )

  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_check_provider_answers_path(@legal_aid_application))
  steps %(Then I should be on a page showing 'Check your answers')
end

Given("I complete the passported journey as far as capital check your answers") do
  applicant = create(
    :applicant,
    first_name: "Test",
    last_name: "Walker",
    national_insurance_number: "JA293483A",
    date_of_birth: "10-01-1980",
    email: "test@test.com",
  )
  create(
    :address,
    address_line_one: "Transport For London",
    address_line_two: "98 Petty France",
    city: "London",
    postcode: "SW1H 9EA",
    lookup_used: true,
    applicant:,
  )
  @legal_aid_application = create(
    :legal_aid_application,
    :with_everything,
    :with_proceedings,
    :with_passported_state_machine,
    :provider_entering_means,
    applicant:,
  )
  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_check_passported_answers_path(@legal_aid_application))
  steps %(Then I should be on a page showing 'Check your answers')
end

Given("I complete the application and view the check your answers page") do
  applicant = create(
    :applicant,
    first_name: "Test",
    last_name: "User",
    national_insurance_number: "CB987654A",
    date_of_birth: "03-04-1999",
  )
  create(
    :address,
    address_line_one: "Transport For London",
    address_line_two: "98 Petty France",
    city: "London",
    postcode: "SW1H 9EA",
    lookup_used: true,
    applicant:,
  )

  @legal_aid_application = create(
    :legal_aid_application,
    :with_non_passported_state_machine,
    :applicant_entering_means,
    :with_proceedings,
    applicant:,
    explicit_proceedings: [:da001],
    set_lead_proceeding: :da001,
  )

  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_check_provider_answers_path(@legal_aid_application))
end

Given("The means questions have been answered by the applicant") do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_proceedings,
    :with_non_passported_state_machine,
    :provider_assessing_means,
    :with_policy_disregards,
    # as we dont categorise on applicant side this traits should be removed, but I expect they will break many tests
    :with_uncategorised_debit_transactions,
    :with_uncategorised_credit_transactions,
    explicit_proceedings: %i[da001 da005],
    set_lead_proceeding: :da001,
  )
  create(:legal_framework_merits_task_list, :da001_da005_as_applicant, legal_aid_application: @legal_aid_application)
  login_as @legal_aid_application.provider
  visit Flow::KeyPoint.path_for(
    journey: :providers,
    key_point: :start_after_applicant_completes_means,
    legal_aid_application: @legal_aid_application,
  )
end

Given("I add the details for a child dependant") do
  steps %(
    Then I fill "Name" with "Wednesday Adams"
    And I enter a date of birth for a 17 year old
    And I choose "Child dependant"
    And I choose option "dependant-in-full-time-education-field"
    And I choose option "dependant-has-income-field"
    And I choose option "dependant-has-assets-more-than-threshold-field"
  )
end

Given("Bank transactions exist") do
  bank_provider = create :bank_provider, applicant: @legal_aid_application.applicant
  bank_account = create(:bank_account, bank_provider:)
  create_list :bank_transaction, 6, :credit, bank_account:
end

Then("I click on the View statements and add transactions link for {string}") do |transaction_type_name|
  within(:css, "div#list-item-#{transaction_type_name.underscore.tr(' ', '_')}") do
    click_link "View statements and add transactions"
  end
end

When("the search for {string} is not successful") do |proceeding_search|
  fill_in("proceeding-search-input", with: proceeding_search)
end

Then("the result list on page returns a {string} message") do |string|
  expect(page).to have_content(string)
end

Then("I visit received benefit confirmation page") do
  visit providers_legal_aid_application_received_benefit_confirmation_path(@legal_aid_application)
end

And("I search for proceeding {string}") do |proceeding_search|
  fill_in("proceeding-search-input", with: proceeding_search)
  wait_for_ajax
end

And(/^I should (see|not see) ['|"](.*?)['|"]$/) do |visibility, text|
  if visibility == "see"
    expect(page).to have_content(/#{text}/)
  else
    expect(page).not_to have_content(text)
  end
end

And(/^I should (see|not see) a govuk formatted date from ['|"](.*?)['|"] days ago$/) do |visibility, number|
  date = number.to_i.days.ago
  text = date.strftime("%-d %B %Y")
  if visibility == "see"
    expect(page).to have_content(/#{text}/)
  else
    expect(page).not_to have_content(text)
  end
end

When(/^I click clear search$/) do
  page.find_by_id("clear-proceeding-search").click
end

Then(/^proceeding search field is empty$/) do
  expect(page).to have_field("proceeding-search-input", with: "")
end

Then(/^the results section is empty$/) do
  expect(page).not_to have_css("#proceeding-list .proceeding-item")
end

Then(/^proceeding suggestions has (results|no results)$/) do |results|
  wait_for_ajax
  case results
  when "results"
    expect(page).to have_css("#proceeding-list .proceeding-item")
  when "no results"
    expect(page).not_to have_css("#proceeding-list .proceeding-item")
  end
end

Given("I click Check Your Answers Change link for {string}") do |question|
  question_id = question.parameterize(separator: "_")

  within "#app-check-your-answers__#{question_id}" do
    click_link("Change")
  end
end

Given("I click Check Your Answers Change link for proceeding {string}") do |question|
  steps %(Then the page should be axe clean skipping: region, aria-allowed-attr) if run_axe?
  question_id = question.parameterize(separator: "_")

  within "#app-check-your-answers__proceeding_#{question_id}" do
    click_link("Change")
  end
end

Given("I click Check Your Answers Change link for dependant {string}") do |dependant|
  within "#app-check-your-answers__dependants_#{dependant}" do
    click_link("Change")
  end
end

Given("I click Check Your Merits Answers Change link for {string} for {string}") do |field_name, meaning|
  proceeding = @legal_aid_application.proceedings.find_by(meaning:)
  field_name.downcase!
  field_name.gsub!(/\s+/, "_")
  within "#app-check-your-answers__#{proceeding.id}_#{field_name}" do
    click_link("Change")
  end
end

Given("I click has other dependants remove link for dependant {string}") do |dependant|
  within "#dependant_#{dependant}" do
    click_link("Remove")
  end
end

Then("I click on the add payments link for income type {string}") do |income_type|
  income_type.downcase!
  within "#income-type-#{income_type}" do
    click_link(I18n.t(".citizens.income_summary.index.select.#{income_type}"))
  end
end

Then("I click on the add payments link for outgoing type {string}") do |outgoing_type|
  outgoing_type.downcase!
  within "#list-item-#{outgoing_type}" do
    click_link(I18n.t(".citizens.outgoings_summary.index.select.#{outgoing_type}"))
  end
end

Then("the answer for {string} should be {string}") do |field_name, answer|
  field_name.downcase!
  field_name.gsub!(/\s+/, "_")
  expect(page).to have_css("#app-check-your-answers__#{field_name}")
  expect(page).to have_content(answer)
end

Then("the answer for all {string} categories should be {string}") do |field_name, expected_answer|
  field_name.downcase!
  field_name.gsub!(/\s+/, "_")
  wrong_answer = expected_answer == "No" ? "Yes" : "No"
  within "#app-check-your-answers__#{field_name}_items" do # search within the section to check that all answers are yes/no
    expect(page).to have_text(expected_answer)
    expect(page).not_to have_text(wrong_answer)
  end
end

Then("the delete modal should open") do
  expect(page).to have_css(".modal-dialog")
end

Then("I click the close button for the modal") do
  find(".close").click
end

Then("the delete modal should not be visible") do
  expect(page).not_to have_css("modal-dialog")
end

Then("I select a proceeding type and continue") do
  find_by_id("proceeding-list").first(:button, "Select and continue").click
end

Then("I choose a proceeding type {string} radio button") do |radio_button_name|
  choose(radio_button_name, allow_label_click: true)
end

Then("I select proceeding type {int}") do |index|
  find_by_id("proceeding-list").all(:button, "Select")[index - 1].click
end

Then("I expect to see {int} proceeding types selected") do |number|
  expect(page).to have_selector(
    ".selected-proceeding-types .selected-proceeding-type",
    count: number,
  )
end

Then("I click the first {string} in selected proceeding types") do |link|
  find(".selected-proceeding-types").first(:link, link).click
end

Then(/^I see the client details page$/) do
  expect(page).to have_content("Enter your client's details")
end

Then("I should be on the Applicant page") do
  expect(page).to have_field("applicant-first-name-field")
end

Then("I enter name {string}, {string}") do |first_name, last_name|
  type = page.title.starts_with?("Enter your client's details") ? "applicant" : "partner"
  fill_in("#{type}-first-name-field", with: first_name)
  fill_in("#{type}-last-name-field", with: last_name)
end

Then(/^I enter the date of birth '(\d+-\d+-\d+)'$/) do |dob|
  day, month, year = dob.split("-")
  type = page.title.starts_with?("Enter your client's details") ? "applicant" : "partner"
  fill_in("#{type}_date_of_birth_3i", with: day)
  fill_in("#{type}_date_of_birth_2i", with: month)
  fill_in("#{type}_date_of_birth_1i", with: year)
end

Then("I enter the email address {string}") do |email|
  field = find("input[name*=email]")[:name]
  fill_in(field, with: email)
end

Then("I enter a date of birth for a {int} year old") do |number|
  date = (number.years + 1.month).ago
  fill_in("dependant_date_of_birth_3i", with: date.day)
  fill_in("dependant_date_of_birth_2i", with: date.month)
  fill_in("dependant_date_of_birth_1i", with: date.year)
end

Then(/^I enter the purchase date '(\d+-\d+-\d+)'$/) do |purchase_date|
  day, month, year = purchase_date.split("-")
  fill_in("purchased_on", with: day)
  fill_in("purchased_on_month", with: month)
  fill_in("purchased_on_year", with: year)
end

Then(/^I enter the (.*) date of (\d+) day(?:s)? ago$/) do |name, number|
  name.gsub!(/\s+/, "_")
  date = number.days.ago
  fields = page.all("input[name*=#{name}]")
  fill_in(fields[0][:name].to_s, with: date.day)
  fill_in(fields[1][:name].to_s, with: date.month)
  fill_in(fields[2][:name].to_s, with: date.year)
end

Then("I should see a {string} date of {int} days ago") do |name, number|
  name.gsub!(/\s+/, "_")
  date = number.days.ago
  fields = page.all("input[name*=#{name}]")
  expect(fields[0][:value]).to eq(date.day.to_s)
  expect(fields[1][:value]).to eq(date.month.to_s)
  expect(fields[2][:value]).to eq(date.year.to_s)
end

Then("I enter a {string} for a {int} year old") do |name, number|
  name.gsub!(/\s+/, "_")
  date = (number.years + 1.month).ago
  fields = page.all("input[name*=#{name}]")
  fill_in(fields[0][:name].to_s, with: date.day)
  fill_in(fields[1][:name].to_s, with: date.month)
  fill_in(fields[2][:name].to_s, with: date.year)
end

Then(/^I enter the (.*) date of (\d+) month(?:s)? in the future$/) do |name, number|
  name.gsub!(/\s+/, "_")
  date = Time.zone.today + number.months
  fields = page.all("input[id*=#{name}]")
  fill_in(fields[0][:name].to_s, with: date.day)
  fill_in(fields[1][:name].to_s, with: date.month)
  fill_in(fields[2][:name].to_s, with: date.year)
end

Given("a {string} exists in the database") do |model|
  model.gsub!(/\s+/, "_")
  create model.to_sym
end

Then(/^I see a notice confirming an e-mail was sent to the citizen$/) do
  expect(page).to have_content("Application completed. An e-mail will be sent to the citizen.")
end

# Matches:
#   Then I enter a field name 'entry'
#   Then I enter the field name "entry"
#   Then I enter field name 'entry'
Then(/^I enter ((a|an|the)\s)?([\w\s]+?) ["']([\w\s]+)["']$/) do |_ignore, field_name, entry|
  field_name.downcase!
  field_id = field_name.gsub(/[\s_]+/, "-")
  field_name.gsub!(/\s+/, "_")
  name = find("input[name*=#{field_name}], ##{field_id}")[:name]
  fill_in(name, with: entry)
end

Then(/^I select the first checkbox$/) do
  page.first("input[type='checkbox']", visible: false).click
end

Then(/^I select the second checkbox$/) do
  page.find("input[type='checkbox']", visible: false)[1].click
end

Then("I check {string}") do |string|
  check string, visible: false
end

Then("I pause") do
  sleep 5
end

Then("I am on the postcode entry page") do
  expect(page).to have_content("Enter your client's correspondence address")
end

Then(/^I click find address$/) do
  click_button("Find address")
end

Then(/^I select an address '(.*)'$/) do |address|
  select(address, from: "address_selection[lookup_id]")
end

Then(/^I select an organisation type '(.*)'$/) do |type|
  select(type, from: "application-merits-task-opponent-organisation-type-ccms-code-field")
end

Then("I am on the application confirmation page") do
  expect(page).to have_content("We've shared your application with your client")
end

Then("I am on the legal aid applications page") do
  expect(page).to have_content("Applications")
end

Then("I am on the About the Financial Assessment page") do
  expect(page).to have_content("Send your client a link to access the service")
end

Then("I am on the check your answers page for other assets") do
  expect(page).to have_content("Check your answers")
  expect(page).to have_content("Which assets does your client have?")
end

Then("I am on the check your answers page for policy disregards") do
  expect(page).to have_content("Check your answers")
  expect(page).to have_content("Payments from scheme or charities")
end

Then("I am on the read only version of the check your answers page") do
  expect(page).to have_content("Home")
  expect(page).not_to have_css(".change-link")
end

Then(/^I click How we checked your client's benefits status$/) do
  page.find_by_id("checked-status").click
end

Then("I am on the {string} page") do |string|
  expect(page).to have_content(string)
end

# rubocop:disable Lint/Debugger
Then("show me the page") do
  save_and_open_page
end

Then("wait a bit") do
  sleep 2
end
# rubocop:enable Lint/Debugger

When("I click the browser back button") do
  page.go_back
end

Then(/^the value of the ['|"](.*)['|"] input should (be|not be) ['|"](.*)['|"]$/) do |id, visibility, answer|
  id.downcase!
  id.gsub!(/\s+/, "-")
  input = page.find(:field, id:, type: "text", exact: false)
  if visibility == "be"
    expect(input.value).to eq answer
  else
    expect(input.value).not_to eq answer
  end
end
