require "rspec/expectations"

Given("I have completed a non-passported application with open banking transactions") do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_employed_applicant,
    :with_single_employment,
    :with_extra_employment_information,
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

  @legal_aid_application.provider.permissions << Permission.find_by(role: "application.non_passported.employment.*")
  @legal_aid_application.provider.permissions << Permission.find_by(role: "application.non_passported.bank_statement_upload.*")
  @legal_aid_application.provider.save!

  login_as @legal_aid_application.provider
end

And("I am viewing the means summary check your anwsers page") do
  visit(providers_legal_aid_application_means_summary_path(@legal_aid_application))
end

Then("the {string} section's questions should exist:") do |section, table|
  section = section.parameterize
  expect_questions_in(selector: "[data-check-your-answers-section=\"#{section}\"]", expected: table)
end

Then("the {string} section's questions and answers should exist:") do |section, table|
  section = section.parameterize
  expect_questions_and_anwsers_in(selector: "[data-check-your-answers-section=\"#{section}\"]", expected: table)
end

def expect_questions_and_anwsers_in(expected:, selector:)
  expected = expected.hashes.map(&:symbolize_keys)
  actual = actual_questions_and_anwsers_in(selector:)

  expected.each do |row|
    expect(actual).to include(row), "expected to find question with \"dt\" tag including \"#{row[:question]}\" and answer with tag \"dd\" including text: \"#{row[:answer]}\""
  end
end

def actual_questions_and_anwsers_in(selector:)
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
