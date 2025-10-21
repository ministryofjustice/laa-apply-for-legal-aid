require "system_helper"
RSpec.describe "Client and case details section - DWP outcome", :javascript, :vcr do
  feature "View and amend the DWP outcome section" do
    before do
      login_as_a_provider
      fill_in_client_and_case_details_until_step(:make_link)
      govuk_choose("No")
      click_on "Save and continue"
    end

    scenario "I can complete the task list's DWP outcome item" do
      @legal_aid_application ||= LegalAidApplication.find(id_from_current_page_url)
      visit providers_legal_aid_application_task_list_path(@legal_aid_application)

      expect_section_with_task_list_items("Client and case details") do
        [
          { name: "Check your answers", link_enabled: true, status: "Not started" },
          { name: "DWP outcome", link_enabled: false, status: "Not ready" },
        ]
      end

      click_on "Check your answers"
      expect(page).to have_css("h1", text: "Check your answers")
      click_on "Save and continue"
      expect(page).to have_css("h1", text: "DWP records show that your client does not get a passporting benefit. Is this correct?")

      visit providers_legal_aid_application_task_list_path(@legal_aid_application)

      expect_section_with_task_list_items("Client and case details") do
        [
          { name: "DWP outcome", link_enabled: true, status: "Not started" },
        ]
      end

      click_on "DWP outcome"
      click_on "This is not correct"

      visit providers_legal_aid_application_task_list_path(@legal_aid_application)

      expect_section_with_task_list_items("Client and case details") do
        [
          { name: "DWP outcome", link_enabled: true, status: "In progress" },
        ]
      end

      click_on "DWP outcome"

      expect(page).to have_css("h1", text: "Check your client's details")
      click_on "Save and continue"

      expect(page).to have_css("h1", text: "Which passporting benefit does your client get?")
      govuk_choose("Universal Credit")
      click_on "Save and continue"

      expect(page).to have_css("h1", text: "Do you have evidence that your client receives Universal Credit?")
      govuk_choose("Yes")
      click_on "Save and continue"

      visit providers_legal_aid_application_task_list_path(@legal_aid_application)

      expect_section_with_task_list_items("Client and case details") do
        [
          { name: "DWP outcome", link_enabled: false, status: "Complete" },
        ]
      end
    end
  end
end
