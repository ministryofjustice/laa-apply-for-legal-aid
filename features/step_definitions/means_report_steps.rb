Given("I have completed a non-passported employed application with bank statement uploads") do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_everything,
    :with_dependant,
    :with_cfe_empty_result,
    :with_extra_employment_information,
    :with_full_employment_information,
    :with_fixed_benefits_cash_transactions,
    :with_fixed_rent_or_mortage_cash_transactions,
    :with_chances_of_success,
    :assessment_submitted,
    provider_received_citizen_consent: false,
    attachments: [build(:attachment, :bank_statement)],
    explicit_proceedings: %i[da002 da006],
    set_lead_proceeding: :da002,
  )

  @legal_aid_application.provider.permissions << Permission.find_by(role: "application.non_passported.employment.*")
  @legal_aid_application.provider.permissions << Permission.find_by(role: "application.non_passported.bank_statement_upload.*")
  @legal_aid_application.provider.save!

  login_as @legal_aid_application.provider
end

Given("I have completed a non-passported employed application with enhanced bank statement uploads") do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_employed_applicant,
    :with_non_passported_state_machine,
    :with_merits_statement_of_case,
    :with_opponent,
    :with_restrictions,
    :with_incident,
    :with_vehicle,
    :with_transaction_period,
    :with_extra_employment_information,
    :with_other_assets_declaration,
    :with_policy_disregards,
    :with_fixed_offline_accounts,
    :with_dependant,
    :with_cfe_v5_result,
    :with_chances_of_success,
    :with_own_home_mortgaged,
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

  @legal_aid_application.provider.permissions << Permission.find_by(role: "application.non_passported.employment.*")
  @legal_aid_application.provider.permissions << Permission.find_by(role: "application.non_passported.bank_statement_upload.*")
  @legal_aid_application.provider.save!

  login_as @legal_aid_application.provider
end

Given("I have completed a non-passported application with truelayer") do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_employed_applicant,
    :with_non_passported_state_machine,
    :with_merits_statement_of_case,
    :with_opponent,
    :with_restrictions,
    :with_incident,
    :with_vehicle,
    :with_transaction_period,
    :with_extra_employment_information,
    :with_other_assets_declaration,
    :with_policy_disregards,
    :with_savings_amount,
    :with_open_banking_consent,
    :with_consent,
    :with_dependant,
    :with_cfe_v5_result,
    :with_chances_of_success,
    :with_own_home_mortgaged,
    :assessment_submitted,
    property_value: 599_999.99,
    outstanding_mortgage_amount: 399_999.99,
    shared_ownership: "partner_or_ex_partner",
    percentage_home: 33.33,
    explicit_proceedings: %i[da002 da006],
    set_lead_proceeding: :da002,
  )

  @legal_aid_application.provider.permissions << Permission.find_by(role: "application.non_passported.employment.*")
  @legal_aid_application.provider.permissions << Permission.find_by(role: "application.non_passported.bank_statement_upload.*")
  @legal_aid_application.provider.save!

  login_as @legal_aid_application.provider
end

Given("I have completed a passported application") do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_applicant_and_address,
    :with_passported_state_machine,
    :with_savings_amount,
    :with_merits_statement_of_case,
    :with_opponent,
    :with_restrictions,
    :with_incident,
    :with_vehicle,
    :with_transaction_period,
    :with_other_assets_declaration,
    :with_policy_disregards,
    :with_savings_amount,
    :with_cfe_v5_result,
    :with_chances_of_success,
    :with_own_home_mortgaged,
    :assessment_submitted,
    provider_received_citizen_consent: true,
    property_value: 599_999.99,
    outstanding_mortgage_amount: 399_999.99,
    shared_ownership: "partner_or_ex_partner",
    percentage_home: 33.33,
    explicit_proceedings: %i[da002 da006],
    set_lead_proceeding: :da002,
  )

  @legal_aid_application.provider.permissions << Permission.find_by(role: "application.non_passported.employment.*")
  @legal_aid_application.provider.permissions << Permission.find_by(role: "application.non_passported.bank_statement_upload.*")
  @legal_aid_application.provider.save!

  login_as @legal_aid_application.provider
end

When("I view the means report") do
  visit(providers_legal_aid_application_means_report_path(@legal_aid_application, debug: true))
end

Then("the following sections should exist:") do |table|
  table.hashes.each do |row|
    expect(page).to have_selector(row[:tag], text: /\A#{Regexp.quote(row[:section])}\z/), "expected to find tag \"#{row[:tag]}\" with text: \"#{row[:section]}\""
  end
end

Then("the following sections should not exist:") do |table|
  table.hashes.each do |row|
    expect(page).not_to have_selector(row[:tag], text: /\A#{Regexp.quote(row[:section])}\z/), "expected not to find tag \"#{row[:tag]}\" with text: \"#{row[:section]}\""
  end
end

Then("the Client details questions should exist:") do |table|
  expect_questions_in(selector: "#client-details-questions", expected: table)
end

Then("the Proceeding eligibility questions should exist:") do |table|
  expect_questions_in(selector: "#proceeding-eligibility-questions", expected: table)
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

Then("the Outgoings questions and answers should match:") do |table|
  expect_matching_questions_and_answers(actual_selector: "#outgoings-details-questions", expected_table: table)
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
  expect_questions_in(selector: "#dependants-questions", expected: table)
end

Then("the Dependants detail questions should exist:") do |table|
  expect_questions_in(selector: "#app-check-your-answers__dependants_1_items", expected: table)
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

Then("the Employment notes questions should exist:") do |table|
  expect_questions_in(selector: "#employment-notes-questions", expected: table)
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

Then("the Property questions should exist:") do |table|
  expect_questions_in(selector: "#property-questions", expected: table)
end

Then("the Vehicles questions should exist:") do |table|
  expect_questions_in(selector: "#vehicles-questions", expected: table)
end

Then("the \"Which bank accounts does your client have?\", for static bank account totals, questions should exist:") do |table|
  expect_questions_in(selector: "#app-check-your-answers__bank_accounts_items", expected: table)
end

Then("the \"Which bank accounts does your client have?\", for open banking accounts, questions should exist:") do |table|
  expect_questions_in(selector: "[data-test=\"applicant-bank-accounts\"]", expected: table)
end

Then("the \"Does your client have any savings accounts they cannot access online?\" questions should exist:") do |table|
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

Then("the \"Bank statements\" questions should exist:") do |table|
  expect_questions_in(selector: "#app-check-your-answers__bank_statements", expected: table)
end

def expect_questions_in(expected:, selector:, negate: false)
  within(selector) do
    expected.hashes.each do |row|
      if negate
        expect(page).not_to have_selector("dt", text: row[:question]), "expected not to find tag \"dt\" with text: \"#{row[:question]}\""
      else
        expect(page).to have_selector("dt", text: row[:question]), "expected to find tag \"dt\" with text: \"#{row[:question]}\""
      end
    end
  end
end

def expect_questions_and_answers_in(expected:, selector:)
  within(selector) do
    expected.hashes.each do |row|
      expect(page).to have_selector("dt", text: row[:question]), "expected to find tag \"dt\" with text: \"#{row[:question]}\""
      expect(page).to have_selector("dd", text: row[:answer]), "expected to find tag \"dd\" with text: \"#{row[:answer]}\""
    end
  end
end
