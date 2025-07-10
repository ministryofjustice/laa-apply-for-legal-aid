require "system_helper"

RSpec.describe "Client and case details section - Link to another application", :vcr do
  feature "View the application task list" do
    before do
      login_as_a_provider

      Setting.setting.update!(linked_applications: true)
    end

    # TODO: we navigate to the task list directly in this system spec but eventually we should be navigating using the on-screen button
    # "Save and go to task lisst" or similar.
    #

    scenario "I can complete the task list's Link to another application item" do
      fill_in_client_and_case_details_until_step(:has_national_insurance_number)

      @legal_aid_application ||= LegalAidApplication.find(id_from_current_page_url)
      visit providers_legal_aid_application_task_list_path(@legal_aid_application)

      expect_section_with_task_list_items("Client and case details") do
        [
          { name: "Client details", link_enabled: true, status: "In progress" },
          { name: "Link to another application", link_enabled: false, status: "Cannot start yet" },
        ]
      end

      click_link "Client details"
      click_on "Save and continue"

      govuk_choose("Yes")
      fill_in("Enter National Insurance number", with: "CB987654A")
      click_on "Save and continue"

      govuk_choose("No")
      click_on "Save and continue"

      govuk_choose("My client's UK home address")
      click_on "Save and continue"

      fill_in("Postcode", with: "SW1H 9EA")
      click_on "Find address"
      govuk_choose "Transport For London, 98 Petty France, London, SW1H 9EA"
      click_on "Use this address"

      visit providers_legal_aid_application_task_list_path(@legal_aid_application)

      expect_section_with_task_list_items("Client and case details") do
        [
          { name: "Client details", link_enabled: false, status: "Completed" },
          { name: "Link to another application", link_enabled: true, status: "Not started" },
        ]
      end

      click_on "Link to another application"

      expect(page).to have_css("h1", text: "Do you want to link this application with another one?")
      govuk_choose("No")
      click_on "Save and come back later"

      visit providers_legal_aid_application_task_list_path(@legal_aid_application)

      expect_section_with_task_list_items("Client and case details") do
        [
          { name: "Client details", link_enabled: false, status: "Completed" },
          { name: "Link to another application", link_enabled: false, status: "Completed" },
        ]
      end
    end
  end
end
