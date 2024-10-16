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
    :with_fixed_offline_savings_accounts,
    :with_restrictions,
    :with_maintenance_in_category,
    :with_fixed_benefits_transactions,
    :with_fixed_benefits_cash_transactions,
    :with_maintenance_in_category,
    :with_fixed_rent_or_mortage_transactions,
    :with_fixed_rent_or_mortage_cash_transactions,
    :with_maintenance_out_category,
    :with_transaction_period,
    :with_policy_disregards,
    :with_open_banking_consent,
    :with_consent,
    :with_dependant,
    :with_own_home_mortgaged,
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

And("I am viewing the means capital check your answers page") do
  visit(providers_legal_aid_application_check_capital_answers_path(@legal_aid_application))
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

def actual_questions_and_answers_in(selector:)
  actual = []

  within(selector) do
    rows = page.find_all(".govuk-summary-list__row")
    expect(rows.size).to be_positive, "expected to find at least one selector matching \".govuk-summary-list__row\""

    rows.each do |row|
      within(row) do
        actual << { question: row.find("dt").text, answer: row.find("dd").text }
      end
    end
  end

  actual
end
