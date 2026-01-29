Given("I have created and submitted an application with the application reference {string}") do |application_ref|
  @legal_aid_application = create(
    :legal_aid_application,
    :with_everything,
    :with_passported_state_machine,
    :with_merits_submitted,
    :with_proceedings,
    applicant: create(:applicant, first_name: "Catelyn", last_name: "Stark"),
    provider: @registered_provider,
    application_ref:,
  )
end

Given("I complete the non-passported journey as far as check your answers for linking") do
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
    provider: @registered_provider,
  )

  visit(providers_legal_aid_application_check_provider_answers_path(@legal_aid_application))
  steps %(Then I should be on a page showing 'Check your answers')
end

Given(/I have linked (and|not) copied the ['|"](.*?)['|"] application with a ['|"](.*?)['|"] link/) do |choice, application_ref, type|
  lead_application = LegalAidApplication.find_by(application_ref:)
  @legal_aid_application.proceedings.destroy_all
  if choice.eql?("and")
    @legal_aid_application.update!(copy_case: true,
                                   copy_case_id: lead_application.id)
  else
    create(:proceeding, :da004, legal_aid_application: @legal_aid_application)
  end
  LinkedApplication.find_or_create_by!(lead_application:,
                                       target_application: lead_application,
                                       confirm_link: true,
                                       associated_application: @legal_aid_application,
                                       link_type_code: type == "Family" ? "FC_LEAD" : "Legal")
end

When("I have neither linked or copied an application") do
  LinkedApplication.find_or_create_by!(associated_application: @legal_aid_application,
                                       link_type_code: "false")
  @legal_aid_application.proceedings.destroy_all
  create(:proceeding, :da004, legal_aid_application: @legal_aid_application, lead_proceeding: true)
end

Then("I visit the check_provider_answers page") do
  visit providers_legal_aid_application_check_provider_answers_path(@legal_aid_application)
end

Then(/^I search for laa reference ["']([\w\s-]+)["']$/) do |entry|
  name = find("input[name*=laa_reference], #laa-reference")[:name]
  fill_in(name, with: entry)
end

Then("the {string} list's questions, answers and action presence should match:") do |section, table|
  section.downcase!
  section.gsub!(/\s+/, "_")
  section = "#app-check-your-answers__#{section}"
  expect_matching_questions_answers_and_actions(actual_selector: section, expected_table: table)
end

def expect_matching_questions_answers_and_actions(actual_selector:, expected_table:)
  expected = expected_table.hashes.map(&:symbolize_keys)
  actual = actual_questions_answers_and_actions_in(selector: actual_selector)

  expect(actual).to match_array(expected)
end

def actual_questions_answers_and_actions_in(selector:)
  actual = []

  within(selector) do
    rows = page.find_all(".govuk-summary-list__row")
    expect(rows.size).to be_positive, "expected to find at least one selector matching \".govuk-summary-list__row\""

    rows.each do |row|
      within(row) do
        actual << {
          question: row.find("dt").text,
          answer: row.find("dd.govuk-summary-list__value").text,
          action: row.find("dd.govuk-summary-list__actions").present?.to_s,
        }
      end
    end
  end

  actual
end

Given("I click Check Providers Answers Change link for {string}") do |question|
  question_id = question.parameterize(separator: "_")

  within ".app-check-your-answers__#{question_id}" do
    click_on("Change")
  end
end
