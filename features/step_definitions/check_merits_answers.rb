Given("I complete the journey as far as check merits answers with a PLF proceeding with second appeal question") do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_non_passported_state_machine,
    :with_positive_benefit_check_result,
    :with_proceedings,
    :with_applicant,
    :with_opponent,
    :with_merits_statement_of_case,
    :with_second_appeal,
    :with_involved_children,
    :checking_merits_answers,
    explicit_proceedings: %i[pbm01a],
    set_lead_proceeding: :pbm01a,
    second_appeal: false,
    original_judge_level: "recorder_circuit_judge",
    court_type: "other_court",
  )
  create(:legal_framework_merits_task_list, :pbm01a_as_applicant, legal_aid_application: @legal_aid_application)

  # Mark other merits questions as complete to enable CYA flow for second appeal
  %i[opponent_name statement_of_case children_application second_appeal].each do |merit_task|
    @legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, merit_task)
  end

  %i[children_proceeding chances_of_success].each do |merit_task|
    @legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:PBM01A, merit_task)
  end

  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_check_merits_answers_path(@legal_aid_application))

  steps %(Then I should be on a page showing 'Check your answers')
end

Then("the \"Second appeal\" check your answers section should contain:") do |table|
  expect_questions_and_answers_in(selector: "#app-check-your-answers__second_appeal", expected: table)
end

Then("the \"Second appeal\" check your answers section should not contain:") do |table|
  expect_questions_in(selector: "#app-check-your-answers__second_appeal", expected: table, negate: true)
end
