Then("the \"Client details\" check your answers section should contain:") do |table|
  expect_questions_and_answers_in(selector: "#client-details-questions", expected: table)
end

Then("the \"Client details\" check your answers section should not contain:") do |table|
  expect_questions_in(selector: "#client-details-questions", expected: table, negate: true)
end

Then("the \"Partner details\" check your answers section should contain:") do |table|
  expect_questions_and_answers_in(selector: "#partner-details-questions", expected: table)
end

Given(/^I have created an application with (.*) proceedings (with|without) delegated functions$/) do |proceedings, df|
  proceeding_array = proceedings.split(",").map(&:to_sym)
  df_options = df == "with" ? proceeding_array.map { |p| { p.upcase => [10.days.ago, 10.days.ago] } }[0] : {}
  applicant = create(
    :applicant,
    first_name: "Test",
    last_name: "Test",
    national_insurance_number: "JA123456A",
    date_of_birth: "01-01-1970",
    email: "test@test.com",
    has_partner: false,
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
    :with_delegated_functions_on_proceedings,
    explicit_proceedings: proceeding_array,
    set_lead_proceeding: proceeding_array.first,
    df_options:,
    applicant:,
  )
  login_as @legal_aid_application.provider
end

And("I view the check provider answers page") do
  visit(providers_legal_aid_application_check_provider_answers_path(@legal_aid_application))
  steps %(Then I should be on a page showing 'Check your answers')
end

Then("the {string} proceeding check your answers section should contain:") do |proceeding_code, table|
  expect_questions_and_answers_in(selector: "##{proceeding_code.downcase}-questions", expected: table)
end

Then(/^the (.*) answer for the (.*) proceeding (should|should not) match (.*)$/) do |question, proceeding_code, match, regex|
  selector = "##{proceeding_code.downcase}-questions"
  answer = Regexp.new(regex)
  within(selector) do
    expect(page).to have_css("dt", text: question), "expected to find tag \"dt\" with text: \"#{question}\""
    if match == "should"
      expect(page).to have_css("dd", text: answer), "expected to find tag \"dd\" with text: \"#{answer}\""
    else
      expect(page).to have_no_css("dd", text: answer), "expected to find tag \"dd\" without text: \"#{answer}\""
    end
  end
end

Then(/^the (emergency|substantive) scope limitation (.*) heading for (.*) should (be|not be) bold$/) do |type, text, proceeding_code, match|
  within("##{proceeding_code.downcase}-questions") do
    within("#app-check-your-answers__#{proceeding_code.downcase}_#{type}_scope_limitations") do
      if match == "be"
        expect(page).to have_css("span.single-scope-limit-heading", text:, visible: :visible)
      else
        expect(page).to have_no_css("span.single-scope-limit-heading", text:)
      end
    end
  end
end
