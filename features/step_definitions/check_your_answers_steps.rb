require "rspec/expectations"

Given("I have completed the income section of a non-passported application with open banking transactions") do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_employed_applicant,
    :with_non_passported_state_machine,
    :with_fixed_offline_savings_accounts,
    :with_maintenance_in_category,
    :with_fixed_benefits_transactions,
    :with_fixed_benefits_cash_transactions,
    :with_maintenance_in_category,
    :with_fixed_rent_or_mortage_transactions,
    :with_fixed_rent_or_mortage_cash_transactions,
    :with_maintenance_out_category,
    :with_transaction_period,
    :with_open_banking_consent,
    :with_consent,
    :with_dependant,
    :checking_means_income,
    explicit_proceedings: %i[da002 da006],
    set_lead_proceeding: :da002,
  )

  create :employment, legal_aid_application: @legal_aid_application, owner_id: @legal_aid_application.applicant.id, owner_type: "Applicant"

  login_as @legal_aid_application.provider
end

Given("I have completed the income and capital sections of a non-passported application with open banking transactions") do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_employed_applicant,
    :with_non_passported_state_machine,
    :with_open_banking_consent,
    :with_consent,
    :with_transaction_period,
    :with_fixed_benefits_transactions,
    :with_fixed_benefits_cash_transactions,
    :with_maintenance_in_category,
    :with_fixed_rent_or_mortage_transactions,
    :with_fixed_rent_or_mortage_cash_transactions,
    :with_maintenance_out_category,
    :with_rent_or_mortgage_regular_transaction,
    :with_housing_benefit_regular_transaction,
    :with_dependant,
    :with_own_home_mortgaged,
    :with_vehicle,
    :with_fixed_offline_savings_accounts,
    :with_restrictions,
    :with_vehicle,
    :with_fixed_offline_savings_accounts,
    :with_other_assets_declaration,
    :with_restrictions,
    :with_mandatory_capital_disregards,
    :with_discretionary_capital_disregards,
    :checking_non_passported_means,
    property_value: rand(1...1_000_000.0).round(2),
    outstanding_mortgage_amount: rand(1...1_000_000.0).round(2),
    shared_ownership: LegalAidApplication::SHARED_OWNERSHIP_YES_REASONS.sample,
    percentage_home: rand(1...99.0).round(2),
    explicit_proceedings: %i[da002 da006],
    set_lead_proceeding: :da002,
  )
  create :employment, legal_aid_application: @legal_aid_application, owner_id: @legal_aid_application.applicant.id, owner_type: "Applicant"

  login_as @legal_aid_application.provider
end

Given("I have completed the income and capital sections of a non-passported application with open banking transactions and partner") do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_employed_applicant_and_employed_partner,
    :with_non_passported_state_machine,
    :with_open_banking_consent,
    :with_consent,
    :with_transaction_period,
    :with_fixed_benefits_transactions,
    :with_fixed_benefits_cash_transactions,
    :with_maintenance_in_category,
    :with_fixed_rent_or_mortage_transactions,
    :with_fixed_rent_or_mortage_cash_transactions,
    :with_maintenance_out_category,
    :with_rent_or_mortgage_regular_transaction,
    :with_housing_benefit_regular_transaction,
    :with_dependant,
    :with_own_home_mortgaged,
    :with_vehicle,
    :with_fixed_offline_savings_accounts,
    :with_restrictions,
    :with_vehicle,
    :with_fixed_offline_savings_accounts,
    :with_other_assets_declaration,
    :with_restrictions,
    :with_mandatory_capital_disregards,
    :with_discretionary_capital_disregards,
    :checking_non_passported_means,
    property_value: rand(1...1_000_000.0).round(2),
    outstanding_mortgage_amount: rand(1...1_000_000.0).round(2),
    shared_ownership: LegalAidApplication::SHARED_OWNERSHIP_YES_REASONS.sample,
    percentage_home: rand(1...99.0).round(2),
    explicit_proceedings: %i[da002 da006],
    set_lead_proceeding: :da002,
  )
  create :employment, legal_aid_application: @legal_aid_application, owner_id: @legal_aid_application.applicant.id, owner_type: "Applicant"

  login_as @legal_aid_application.provider
end

Given("I have completed the income and capital sections of a non-passported application with bank statement uploads") do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_employed_applicant_and_extra_info,
    :with_non_passported_state_machine,
    :with_vehicle,
    :with_transaction_period,
    :with_rent_or_mortgage_regular_transaction,
    :with_housing_benefit_regular_transaction,
    :with_dependant,
    :with_own_home_mortgaged,
    :with_fixed_offline_accounts,
    :with_other_assets_declaration,
    :with_mandatory_capital_disregards,
    :with_discretionary_capital_disregards,
    :with_restrictions,
    :checking_non_passported_means,
    property_value: rand(1...1_000_000.0).round(2),
    outstanding_mortgage_amount: rand(1...1_000_000.0).round(2),
    shared_ownership: LegalAidApplication::SHARED_OWNERSHIP_YES_REASONS.sample,
    percentage_home: rand(1...99.0).round(2),
    explicit_proceedings: %i[da002 da006],
    set_lead_proceeding: :da002,
    provider_received_citizen_consent: false,
    attachments: [build(:attachment, :bank_statement)],
  )

  create :employment, legal_aid_application: @legal_aid_application, owner_id: @legal_aid_application.applicant.id, owner_type: "Applicant"

  login_as @legal_aid_application.provider
end

Given("I have completed the income and capital sections of a non-passported application with bank statement uploads and partner") do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_employed_applicant_and_employed_partner,
    :with_non_passported_state_machine,
    :with_vehicle,
    :with_transaction_period,
    :with_rent_or_mortgage_regular_transaction,
    :with_housing_benefit_regular_transaction,
    :with_dependant,
    :with_own_home_mortgaged,
    :with_fixed_offline_accounts,
    :with_other_assets_declaration,
    :with_mandatory_capital_disregards,
    :with_discretionary_capital_disregards,
    :with_restrictions,
    :checking_non_passported_means,
    property_value: rand(1...1_000_000.0).round(2),
    outstanding_mortgage_amount: rand(1...1_000_000.0).round(2),
    shared_ownership: LegalAidApplication::SHARED_OWNERSHIP_YES_REASONS.sample,
    percentage_home: rand(1...99.0).round(2),
    explicit_proceedings: %i[da002 da006],
    set_lead_proceeding: :da002,
    provider_received_citizen_consent: false,
    attachments: [build(:attachment, :bank_statement)],
  )

  create :employment, legal_aid_application: @legal_aid_application, owner_id: @legal_aid_application.applicant.id, owner_type: "Applicant"

  login_as @legal_aid_application.provider
end

Given("I have completed the capital sections of passported application") do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_applicant_and_address,
    :with_passported_state_machine,
    :with_transaction_period,
    :with_own_home_mortgaged,
    :with_vehicle,
    :with_savings_amount,
    :with_other_assets_declaration,
    :with_mandatory_capital_disregards,
    :with_discretionary_capital_disregards,
    :with_restrictions,
    :checking_passported_answers,
    property_value: 599_999.99,
    outstanding_mortgage_amount: 399_999.99,
    shared_ownership: "partner_or_ex_partner",
    percentage_home: 33.33,
    explicit_proceedings: %i[da002 da006],
    set_lead_proceeding: :da002,
  )

  login_as @legal_aid_application.provider
end

Given("I have completed the capital sections of passported application and have a partner") do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_employed_applicant_and_employed_partner,
    :with_passported_state_machine,
    :with_transaction_period,
    :with_own_home_mortgaged,
    :with_vehicle,
    :with_savings_amount,
    :with_other_assets_declaration,
    :with_mandatory_capital_disregards,
    :with_discretionary_capital_disregards,
    :with_restrictions,
    :checking_passported_answers,
    property_value: 599_999.99,
    outstanding_mortgage_amount: 399_999.99,
    shared_ownership: "partner_or_ex_partner",
    percentage_home: 33.33,
    explicit_proceedings: %i[da002 da006],
    set_lead_proceeding: :da002,
  )

  login_as @legal_aid_application.provider
end

And("I am viewing the means capital check your answers page") do
  visit(providers_legal_aid_application_check_capital_answers_path(@legal_aid_application))
end

And("I am viewing the passported capital check your answers page") do
  visit(providers_legal_aid_application_check_passported_answers_path(@legal_aid_application))
end

And("I am viewing the means income check your answers page") do
  visit(providers_legal_aid_application_means_check_income_answers_path(@legal_aid_application))
end

Then("the {string} section's questions should exist:") do |section, table|
  section = section.parameterize
  expect_questions_in(selector: "[data-check-your-answers-section=\"#{section}\"]", expected: table)
end

Then("the {string} section's questions and answers should match:") do |section, table|
  section = section.parameterize
  expect_matching_questions_and_answers(actual_selector: "[data-check-your-answers-section=\"#{section}\"]", expected_table: table)
end

Then("the {string} list's questions and answers should match:") do |section, table|
  section.downcase!
  section.gsub!(/\s+/, "_")
  section = "#app-check-your-answers__#{section}"
  expect_matching_questions_and_answers(actual_selector: section, expected_table: table)
end

Then("the Disregarded payment {int} questions and answers should match:") do |index, table|
  selector = "#mandatory-capital-disregard-questions_#{index - 1}"
  expect_matching_questions_and_answers(actual_selector: selector, expected_table: table)
end

Then("the Payment to be reviewed {int} questions and answers should match:") do |index, table|
  selector = "#discretionary-capital-disregard-questions_#{index - 1}"
  expect_matching_questions_and_answers(actual_selector: selector, expected_table: table)
end

Then("the radio button response for {string} should be {string}") do |question, answer|
  question.downcase!
  question.gsub!(/\s+/, "-")
  value = answer == "Yes" ? "-true" : ""
  label = find("label[for='#{question}#{value}-field']")
  input = label.sibling("input", visible: false)
  expect(input).to be_checked
end

def expect_matching_questions_and_answers(actual_selector:, expected_table:)
  expected = expected_table.hashes.map(&:symbolize_keys)
  actual = actual_questions_and_answers_in(selector: actual_selector)

  expect(actual).to match_array(expected), SuperDiff.diff(expected, actual)
end

def expect_regex_match_for_questions_and_answers(actual_selector:, expected_table:)
  expected = expected_table.hashes.map(&:symbolize_keys)
  actual = actual_questions_and_answers_in(selector: actual_selector)

  expected.each do |expected_row|
    match_found = false

    actual.each do |actual_row|
      next unless actual_row[:question].match?(expected_row[:question])

      expect(actual_row[:question]).to match(expected_row[:question])
      expect(actual_row[:answer]).to match(expected_row[:answer])
      match_found = true
    end

    next if match_found

    expect(1).to eql(2), "No matching questions and answers for #{expected_row[:question]}, #{expected_row[:answer]}!"
  end
end

def actual_questions_and_answers_in(selector:)
  actual = []

  within(selector) do
    rows = page.find_all(".govuk-summary-list__row")
    expect(rows.size).to be_positive, "expected to find at least one selector matching \".govuk-summary-list__row\""

    rows.each do |row|
      within(row) do
        actual << { question: row.first("dt").text, answer: row.first("dd").text }
      end
    end
  end

  actual
end

def expect_single_question_and_answer(actual_selector:, expected_table:)
  expected = expected_table.hashes.map(&:symbolize_keys)
  actual = actual_single_question_and_answer_in(selector: actual_selector)

  expect(actual).to match_array(expected), SuperDiff.diff(expected, actual)
end

def actual_single_question_and_answer_in(selector:)
  actual = []

  within(selector) do
    actual << { question: page.find("dt").text, answer: page.find("dd").text }
  end

  actual
end
