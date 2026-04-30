module StepHelpers
  # Usage specify one of the step names to complete the steps
  # and leave you on that step's page.
  # e.g.
  # fill_in_client_and_case_details_until_step(:has_national_insurance_number)
  #
  def fill_in_client_and_case_details_until_step(step_name)
    visit "/"
    click_on "Start"

    govuk_choose("Test Firm, Office 1 Address Line 1, Office 1 Address Line 2, Test City 1, TE5T1NG")
    click_on "Save and continue"
    click_on "Make a new application"

    expect(page).to have_css("h1", text: "Declaration")

    click_on "Agree and continue"
    expect(page).to have_css("h1", text: "Enter your client's details")

    fill_in("First name", with: "Test")
    fill_in("Last name", with: "User")

    govuk_choose("No")
    govuk_fill_in_date_field(text: "Date of birth", date: 21.years.ago)

    click_on "Save and continue"
    expect(page).to have_css("h1", text: "Does your client have a National Insurance number?")

    return if step_name == :has_national_insurance_number

    govuk_choose("Yes")
    fill_in("Enter National Insurance number", with: "CB987654A")

    click_on "Save and continue"
    expect(page).to have_css("h1", text: "Clients who have applied before")
    expect(page).to have_css("h2", text: "Has your client applied for civil legal aid before?")

    return if step_name == :previous_references

    govuk_choose("No")
    click_on "Save and continue"

    return if step_name == :correspondence_address

    govuk_choose("My client's UK home address")
    click_on("Save and continue")

    fill_in("Postcode", with: "SW1H 9EA")
    click_on "Find address"

    govuk_choose "Transport For London, 98 Petty France, London, SW1H 9EA"
    click_on "Use this address"

    expect(page).to have_css("h1", text: "Linking cases")

    return if step_name == :link_application

    govuk_choose("No")
    click_on "Save and continue"

    expect(page).to have_css("h1", text: "What does your client want legal aid for?")

    return if step_name == :proceedings

    fill_in("proceeding-search-input", with: "da004")
    govuk_choose("Non-molestation order", match: :prefer_exact)
    click_on "Save and continue"

    govuk_choose "No"
    click_on "Save and continue"

    govuk_choose "Applicant, claimant or petitioner"
    click_on "Save and continue"

    govuk_choose "No"
    click_on "Save and continue"

    govuk_choose "Yes"
    click_on "Save and continue"

    click_on "Save and continue"

    expect(page).to have_css("h1", text: "Your client's partner")

    return if step_name == :partner

    govuk_choose "No"
    click_on "Save and continue"

    expect(page).to have_css("h1", text: "Check your answers")

    nil if step_name == :check_your_answers
  end

  def create_an_application_and_complete_client_details(with_partner)
    applicant = with_partner ? :with_applicant_and_partner : :with_applicant
    @legal_aid_application = create(
      :application,
      :with_proceedings,
      :at_entering_applicant_details,
      applicant,
      provider: @registered_provider,
    )
  end
end
