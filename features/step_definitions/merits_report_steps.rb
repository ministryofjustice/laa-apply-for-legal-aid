Given("I complete the journey as far as check merits answers with multiple proceedings with delegated functions") do
  matter_opposition = create(:matter_opposition)
  allegation = create(:allegation)
  undertaking = create(:undertaking)
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
    :with_involved_children,
    :with_opponent,
    matter_opposition:,
    allegation:,
    undertaking:,
    explicit_proceedings: %i[da001 da004 se014],
    set_lead_proceeding: :da001,
  )
  create(:legal_framework_merits_task_list, :da001_da004_as_defendant_se014, legal_aid_application: @legal_aid_application)
  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_check_merits_answers_path(@legal_aid_application))

  steps %(Then I should be on a page showing 'Check your answers')
end

When("I view the merits report") do
  visit(providers_legal_aid_application_merits_report_path(@legal_aid_application, debug: true))
end

Then("the Previous Legal Aid questions and answers should match:") do |table|
  expect_regex_match_for_questions_and_answers(actual_selector: "#app-check-your-answers__applied_previously__summary", expected_table: table)
end

Then("the What you're applying for questions and answers should match:") do |table|
  expect_matching_questions_and_answers(actual_selector: "#app-check-your-answers__proceedings_details__summary", expected_table: table)
end

Then("the {string} questions and answers should match:") do |id, table|
  expect_regex_match_for_questions_and_answers(actual_selector: "##{id}", expected_table: table)
end

Then("I can see {string} within {string}") do |text, selector|
  within(selector) do
    expect(page).to have_content(text)
  end
end

Then("the Emergency cost limit questions and answers should match:") do |table|
  expect_matching_questions_and_answers(actual_selector: "#app-check-your-answers__emergency_cost_overrides", expected_table: table)
end

Then("the Opponents questions and answers should match:") do |table|
  expect_regex_match_for_questions_and_answers(actual_selector: "#app-check-your-answers__opponent", expected_table: table)
end

Then("the Mental capacity questions and answers should match:") do |table|
  expect_regex_match_for_questions_and_answers(actual_selector: "#app-check-your-answers__mental_capacity", expected_table: table)
end

Then("the Domestic abuse summary questions and answers should match:") do |table|
  expect_regex_match_for_questions_and_answers(actual_selector: "#app-check-your-answers__domestic_abuse", expected_table: table)
end

Then("the Children involved in this application questions and answers should match:") do |table|
  expect_regex_match_for_questions_and_answers(actual_selector: "#app-check-your-answers__children_involved", expected_table: table)
end

Then("the Why the matter is opposed questions and answers should match:") do |table|
  expect_regex_match_for_questions_and_answers(actual_selector: "#app-check-your-answers__matter_opposition", expected_table: table)
end

Then("the Allegation questions and answers should match:") do |table|
  expect_regex_match_for_questions_and_answers(actual_selector: "#app-check-your-answers__allegation", expected_table: table)
end

Then("the Section 8 and LASPO questions and answers should match:") do |table|
  expect_regex_match_for_questions_and_answers(actual_selector: "#app-check-your-answers__laspo", expected_table: table)
end

Then("the Offer of undertakings questions and answers should match:") do |table|
  expect_regex_match_for_questions_and_answers(actual_selector: "#app-check-your-answers__undertaking", expected_table: table)
end

Then("the Statement of case questions and answers should match:") do |table|
  expect_regex_match_for_questions_and_answers(actual_selector: "#app-check-your-answers__statement_of_case", expected_table: table)
end
