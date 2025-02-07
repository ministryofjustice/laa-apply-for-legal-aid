Given(/^I have completed a non-passported (employed|employed with partner) application with bank statement uploads$/) do |optional_partner|
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_employed_applicant_and_extra_info,
    :with_non_passported_state_machine,
    :with_vehicle,
    :with_transaction_period,
    :with_rent_or_mortgage_regular_transaction,
    :with_housing_benefit_regular_transaction,
    :with_other_assets_declaration,
    :with_mandatory_capital_disregards,
    :with_discretionary_capital_disregards,
    :with_restrictions,
    :with_fixed_offline_accounts,
    :with_dependant,
    :with_own_home_mortgaged,
    :with_merits_statement_of_case,
    :with_opponent,
    :with_incident,
    :with_parties_mental_capacity,
    :with_domestic_abuse_summary,
    :with_chances_of_success,
    :assessment_submitted,
    property_value: 599_999.99,
    outstanding_mortgage_amount: 399_999.99,
    shared_ownership: "partner_or_ex_partner",
    percentage_home: 33.33,
    explicit_proceedings: %i[da002 da006],
    set_lead_proceeding: :da002,
    provider_received_citizen_consent: false,
    attachments: [build(:attachment, :bank_statement)],
  )

  create :legal_framework_merits_task_list, :da002_da006_as_applicant, legal_aid_application: @legal_aid_application

  cfe_submission = create(:cfe_submission, legal_aid_application: @legal_aid_application)
  if optional_partner == "employed with partner"
    create(:cfe_v6_result, :with_partner, submission: cfe_submission, legal_aid_application: @legal_aid_application)
    create(:partner, :with_extra_employment_information, legal_aid_application: @legal_aid_application)
    @legal_aid_application.applicant.update!(has_partner: true, partner_has_contrary_interest: false)
  else
    create(:cfe_v6_result, submission: cfe_submission, legal_aid_application: @legal_aid_application)
  end

  login_as @legal_aid_application.provider
end

Given(/^I have completed a (non-passported|non-passported with partner) application with truelayer$/) do |optional_partner|
  bank_provider = create(:bank_provider)
  create(
    :bank_account,
    bank_provider:,
    name: "Account Name",
    account_number: "12345678",
    sort_code: "000000",
    balance: "75.57",
  )
  create(
    :bank_account,
    bank_provider:,
    name: "Second Account",
    account_number: "87654321",
    sort_code: "999999",
    balance: "57.57",
  )
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_employed_applicant_and_extra_info,
    :with_non_passported_state_machine,
    :with_restrictions,
    :with_vehicle,
    :with_transaction_period,
    :with_other_assets_declaration,
    :with_mandatory_capital_disregards,
    :with_discretionary_capital_disregards,
    :with_savings_amount,
    :with_open_banking_consent,
    :with_consent,
    :with_dependant,
    :with_cfe_v6_result,
    :with_own_home_mortgaged,
    :with_merits_statement_of_case,
    :with_incident,
    :with_opponent,
    :with_parties_mental_capacity,
    :with_domestic_abuse_summary,
    :with_chances_of_success,
    :assessment_submitted,
    property_value: 599_999.99,
    outstanding_mortgage_amount: 399_999.99,
    shared_ownership: "partner_or_ex_partner",
    percentage_home: 33.33,
    explicit_proceedings: %i[da002 da006],
    set_lead_proceeding: :da002,
  )

  @legal_aid_application.applicant.update!(bank_providers: [bank_provider])

  create :legal_framework_merits_task_list, :da002_da006_as_applicant, legal_aid_application: @legal_aid_application

  cfe_submission = create(:cfe_submission, legal_aid_application: @legal_aid_application)
  if optional_partner == "non-passported with partner"
    create(:cfe_v6_result, :with_partner, submission: cfe_submission, legal_aid_application: @legal_aid_application)
    create(:partner, :with_extra_employment_information, legal_aid_application: @legal_aid_application)
    @legal_aid_application.applicant.update!(has_partner: true, partner_has_contrary_interest: false)
  else
    create(:cfe_v6_result, submission: cfe_submission, legal_aid_application: @legal_aid_application)
  end

  login_as @legal_aid_application.provider
end

Given("I have completed a passported application") do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_applicant_and_address,
    :with_passported_state_machine,
    :with_savings_amount,
    :with_restrictions,
    :with_vehicle,
    :with_transaction_period,
    :with_other_assets_declaration,
    :with_mandatory_capital_disregards,
    :with_discretionary_capital_disregards,
    :with_savings_amount,
    :with_cfe_v5_result,
    :with_own_home_mortgaged,
    :with_merits_statement_of_case,
    :with_opponent,
    :with_incident,
    :with_chances_of_success,
    :assessment_submitted,
    provider_received_citizen_consent: true,
    property_value: 599_999.99,
    outstanding_mortgage_amount: 399_999.99,
    shared_ownership: "partner_or_ex_partner",
    percentage_home: 33.33,
    explicit_proceedings: %i[da002 da006],
    set_lead_proceeding: :da002,
  )

  login_as @legal_aid_application.provider
end

Given("I have completed a non means tested application") do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_under_18_applicant,
    :with_skipped_benefit_check_result,
    :with_non_means_tested_state_machine,
    :with_cfe_empty_result,
    :with_merits_statement_of_case,
    :with_opponent,
    :with_incident,
    :with_chances_of_success,
    :assessment_submitted,
  )

  login_as @legal_aid_application.provider
end

When("I view the means report") do
  visit(providers_legal_aid_application_means_report_path(@legal_aid_application, debug: true))
end

Then("the Client details questions should exist:") do |table|
  expect_questions_in(selector: "#client-details-questions", expected: table)
end

Then("the Client questions and answers should match:") do |table|
  expect_regex_match_for_questions_and_answers(actual_selector: "#client-details-questions", expected_table: table)
end

Then("the Proceeding eligibility questions should exist:") do |table|
  expect_questions_in(selector: "#proceeding-eligibility-questions", expected: table)
end

Then("the Passported means question and answer should match:") do |table|
  expect_single_question_and_answer(actual_selector: "#app-check-your-answers__receives_benefit", expected_table: table)
end

Then("the Income result questions should exist:") do |table|
  expect_questions_in(selector: "#income-result-questions", expected: table)
end

Then("the Income questions and answers should match:") do |table|
  expect_matching_questions_and_answers(actual_selector: "#income-details-questions", expected_table: table)
end

Then("the Deductions questions should exist:") do |table|
  expect_questions_in(selector: "#deductions-details-questions", expected: table)
end

Then("the Deductions questions should not exist:") do |table|
  expect_questions_in(selector: "#deductions-details-questions", expected: table, negate: true)
end

Then("the Capital result questions should exist:") do |table|
  expect_questions_in(selector: "#capital-result-questions", expected: table)
end

Then("the Outgoings and deductions questions and answers should match:") do |table|
  expect_matching_questions_and_answers(actual_selector: "#outgoings-and-deductions-details-questions", expected_table: table)
end

Then("the Declared income categories questions should exist:") do |table|
  expect_questions_in(selector: "#income-category-questions", expected: table)
end

Then("the Declared cash income questions should exist:") do |table|
  expect_questions_in(selector: "#income-cash-payments-questions", expected: table)
end

Then("the Student finance questions should exist:") do |table|
  expect_questions_in(selector: "#student-finance-questions", expected: table)
end

Then("the Dependants questions should exist:") do |table|
  expect_questions_in(selector: "#app-check-your-answers__dependants", expected: table)
end

Then("the Dependants detail questions should exist:") do |table|
  expect_questions_in(selector: "#app-check-your-answers__dependant_1", expected: table)
end

Then("the Declared outgoings categories questions should exist:") do |table|
  expect_questions_in(selector: "#outgoings-category-questions", expected: table)
end

Then("the Declared cash outgoings questions should exist:") do |table|
  expect_questions_in(selector: "#outgoings-cash-payments-questions", expected: table)
end

Then("the Employment income result questions should exist:") do |table|
  expect_questions_in(selector: "#income-result-questions", expected: table)
end

Then("the Employment income result questions should not exist:") do |table|
  expect_questions_in(selector: "#income-result-questions", expected: table, negate: true)
end

Then("the {string} employment notes questions should exist:") do |individual, table|
  expect_questions_in(selector: "#employment-#{individual.downcase}-notes-questions", expected: table)
end

Then("the Employment income questions should exist:") do |table|
  expect_questions_in(selector: "#employment-income-questions", expected: table)
end

Then("the Caseworker review questions should exist:") do |table|
  expect_questions_in(selector: "#caseworker-review-questions", expected: table)
end

Then("the Caseworker review section should contain:") do |table|
  expect_questions_and_answers_in(selector: "#caseworker-review-questions", expected: table)
end

Then("the Property question should exist:") do |table|
  expect_questions_in(selector: "#property-question", expected: table)
end

Then("the Property details questions should exist:") do |table|
  expect_questions_in(selector: "#property-details-questions", expected: table)
end

Then("the Vehicle ownership question should exist:") do |table|
  expect_questions_in(selector: "#vehicles-questions", expected: table)
end

Then("the Vehicles questions should exist:") do |table|
  @legal_aid_application.vehicles.each_with_index do |_vehicle, index|
    expect_questions_in(selector: "#vehicle-questions__#{index}", expected: table)
  end
end

Then("the \"Bank accounts\", for static bank account totals, questions should exist:") do |table|
  expect_questions_in(selector: "#app-check-your-answers__bank_accounts_items", expected: table)
end

Then("the {string} \"Bank accounts\", for static bank account totals, questions should exist:") do |individual, table|
  expect_questions_in(selector: "[data-test=\"#{individual.downcase}-bank-accounts\"]", expected: table)
end

Then("the \"Bank accounts\", for open banking accounts, questions should exist:") do |table|
  expect_questions_in(selector: "[data-test=\"applicant-bank-accounts\"]", expected: table)
end

Then("the \"Bank accounts\", for open banking accounts, questions and answers table should exist:") do |table|
  expect_matching_questions_and_answers(actual_selector: "#applicant-bank-accounts-details", expected_table: table)
end

Then("the \"Your client's accounts\" questions should exist:") do |table|
  expect_questions_in(selector: "[data-test=\"offline-savings-accounts\"]", expected: table)
end

Then("the \"Which savings or investments does your client have?\" questions should exist:") do |table|
  expect_questions_in(selector: "#app-check-your-answers__savings_and_investments_items", expected: table)
end

Then("the \"Which assets does your client have?\" questions should exist:") do |table|
  expect_questions_in(selector: "#app-check-your-answers__other_assets_items", expected: table)
end

Then("the \"Restrictions on your client's assets\" questions should exist:") do |table|
  expect_questions_in(selector: "#restrictions-on-clients-assets-questions", expected: table)
end

Then("the \"Payments from scheme or charities\" questions should exist:") do |table|
  expect_questions_in(selector: "#app-check-your-answers__policy_disregards_items", expected: table)
end

Then("the Capital disregards questions and answers should match:") do |table|
  expect_matching_questions_and_answers(actual_selector: "#capital-disregards-questions", expected_table: table)
end

Then("the \"Bank statements\" questions should exist:") do |table|
  expect_questions_in(selector: "#app-check-your-answers__bank_statements", expected: table)
end
