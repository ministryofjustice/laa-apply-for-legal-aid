module StepHelpers
  # Usage specify one of the step names to complete the steps
  # and leave you on that step's page.
  # e.g.
  # fill_in_client_and_case_details_until_step(:has_national_insurance_number)
  #
  def fill_in_client_and_case_details_until_step(step_name)
    visit "/"
    click_on "Sign in"

    govuk_choose("London")
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
    expect(page).to have_css("h1", text: "Has your client applied for civil legal aid before?")

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

    return if step_name == :proceedings_types

    fill_in("proceeding-search-input", with: "Non-molestation order")
    click_on "Non-molestation order"
    click_on("Save and continue")

    govuk_choose("No")
    click_on("Save and continue")

    govuk_choose("Applicant, claimant or petitioner")
    click_on("Save and continue")

    # Delegated functions
    govuk_choose("No")
    click_on("Save and continue")

    govuk_choose("Yes")
    click_on("Save and continue")

    # Limitations
    click_on("Save and continue")

    # Partner
    govuk_choose("No")
    click_on("Save and continue")

    return if step_name == :check_provider_answers

    # Check your answers
    click_on("Save and continue")
    nil if step_name == :confirm_dwp_non_passported_applications
  end
end
