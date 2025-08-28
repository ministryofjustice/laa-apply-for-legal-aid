module StepHelpers
  # Usage specify one of the step names to complete the steps
  # and leave you on that step's page.
  # e.g.
  # fill_in_client_and_case_details_until_step(:has_national_insurance_number)
  #
  def fill_in_client_and_case_details_until_step(step_name)
    visit "/"
    click_on "Start"

    govuk_choose("0X395U")
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

    nil if step_name == :previous_references
  end

  def create_an_application_and_complete_client_details(with_partner)
    applicant = with_partner ? :with_applicant : :with_applicant_and_partner
    @legal_aid_application = create(
      :application,
      :with_proceedings,
      :at_entering_applicant_details,
      applicant,
      provider: @registered_provider,
    )
  end
end
