require "system_helper"
RSpec.describe "Client and case details section - Client details", :vcr do
  feature "View and amend client details" do
    before do
      login_as_a_provider

      Setting.setting.update!(linked_applications: true)
    end

    # TODO: we navigate to the task list directly at time of writing but eventually we should be
    # navigating using  the on-screen button "Save and go to task list" or similar.
    #

    scenario "I can complete the task list's Client details item" do
      fill_in_client_and_case_details_until_step(:has_national_insurance_number)

      @legal_aid_application ||= LegalAidApplication.find(id_from_current_page_url)
      visit providers_legal_aid_application_task_list_path(@legal_aid_application)

      expect_section_with_task_list_items("Client and case details") do
        [
          { name: "Client details", link_enabled: true, status: "In progress" },
        ]
      end

      click_link "Client details"
      expect(page).to have_css("h1", text: "Enter your client's details")

      click_on "Save and continue"
      expect(page).to have_css("h1", text: "Does your client have a National Insurance number?")
      govuk_choose("Yes")
      fill_in("Enter National Insurance number", with: "CB987654A")

      click_on "Save and continue"
      expect(page).to have_css("h1", text: "Has your client applied for civil legal aid before?")
      govuk_choose("No")

      click_on "Save and continue"
      expect(page).to have_css("h1", text: "Where should we send your client's correspondence?")
      govuk_choose("My client's UK home address")

      click_on "Save and continue"
      expect(page).to have_css("h1", text: "Find your client's home address")
      fill_in("Postcode", with: "SW1H 9EA")
      click_on "Find address"

      govuk_choose "Transport For London, 98 Petty France, London, SW1H 9EA"
      click_on "Use this address"

      expect(page).to have_css("h1", text: "Do you want to link this application with another one?")
      govuk_choose("No")
      click_on "Save and continue"

      expect(page).to have_css("h1", text: "What does your client want legal aid for?")

      visit providers_legal_aid_application_task_list_path(@legal_aid_application)

      expect_section_with_task_list_items("Client and case details") do
        [
          { name: "Client details", link_enabled: false, status: "Completed" },
        ]
      end
    end
  end
end
