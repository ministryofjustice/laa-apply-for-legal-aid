Given("I have completed a non-passported employed application with bank statement uploads") do
  Setting.setting.update!(enable_employed_journey: true)

  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_everything,
    :with_cfe_empty_result,
    :with_extra_employment_information,
    :with_full_employment_information,
    :assessment_submitted,
    :with_chances_of_success,
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

When("I view the means report") do
  visit(providers_legal_aid_application_means_report_path(@legal_aid_application, debug: true))
end

Then("the following sections should exit:") do |table|
  table.hashes.each do |row|
    expect(page).to have_selector(row[:tag], text: row[:section]), "expected to find tag \"#{row[:tag]}\" with text: \"#{row[:section]}\""
  end
end

Then("the following client questions should exist:") do |table|
  expect_questions_in(selector: "#client-details-questions", expected: table)
end

Then("the Declared income categories questions should exist:") do |table|
  expect_questions_in(selector: "#income-category-questions", expected: table)
end

Then("the Student finance questions should exist:") do |table|
  expect_questions_in(selector: "#student-finance-questions", expected: table)
end

Then("the Dependants questions should exist:") do |table|
  expect_questions_in(selector: "#dependants-questions", expected: table)
end

Then("the Declared outgoings categories questions should exist:") do |table|
  expect_questions_in(selector: "#outgoings-category-questions", expected: table)
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

Then("the Property questions should exist:") do |table|
  expect_questions_in(selector: "#property-questions", expected: table)
end

Then("the Vehicles questions should exist:") do |table|
  expect_questions_in(selector: "#vehicles-questions", expected: table)
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

def expect_questions_in(expected:, selector:)
  within(selector) do
    expected.hashes.each do |row|
      expect(page).to have_selector("dt", text: row[:question]), "expected to find tag \"dt\" with text: \"#{row[:question]}\""
    end
  end
end
