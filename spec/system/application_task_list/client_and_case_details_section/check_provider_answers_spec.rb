require "system_helper"
RSpec.describe "Client and case details section - Check your answers", :vcr do
  feature "View check your answers" do
    before do
      login_as_a_provider
    end

    scenario "I can complete the task list's Check your answers item" do
      fill_in_client_and_case_details_until_step(:proceedings)

      @legal_aid_application ||= LegalAidApplication.find(id_from_current_page_url)
      visit providers_legal_aid_application_task_list_path(@legal_aid_application)

      expect_section_with_task_list_items("Client and case details") do
        [
          { name: "Client details", link_enabled: false, status: "Completed" },
          { name: "Link to another application", link_enabled: false, status: "Completed" },
          { name: "Proceedings", link_enabled: true, status: "Not started" },
          { name: "Check your answers", link_enabled: false, status: "Not ready yet" },
          { name: "DWP outcome", link_enabled: false, status: "Not ready yet" },
        ]
      end

      click_on "Proceedings"

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

      govuk_choose "No"
      click_on "Save and continue"

      visit providers_legal_aid_application_task_list_path(@legal_aid_application)

      expect_section_with_task_list_items("Client and case details") do
        [
          { name: "Client details", link_enabled: false, status: "Completed" },
          { name: "Link to another application", link_enabled: false, status: "Completed" },
          { name: "Proceedings", link_enabled: false, status: "Completed" },
          { name: "Check your answers", link_enabled: true, status: "Not started" },
          { name: "DWP outcome", link_enabled: false, status: "Not ready yet" },
        ]
      end

      click_on "Check your answers"
      click_on "Save and come back later"

      visit providers_legal_aid_application_task_list_path(@legal_aid_application)

      expect_section_with_task_list_items("Client and case details") do
        [
          { name: "Client details", link_enabled: false, status: "Completed" },
          { name: "Link to another application", link_enabled: false, status: "Completed" },
          { name: "Proceedings", link_enabled: false, status: "Completed" },
          { name: "Check your answers", link_enabled: true, status: "In progress" },
          { name: "DWP outcome", link_enabled: false, status: "Not ready yet" },
        ]
      end

      click_on "Check your answers"
      click_on "Save and continue"

      visit providers_legal_aid_application_task_list_path(@legal_aid_application)

      expect_section_with_task_list_items("Client and case details") do
        [
          { name: "Client details", link_enabled: false, status: "Completed" },
          { name: "Link to another application", link_enabled: false, status: "Completed" },
          { name: "Proceedings", link_enabled: false, status: "Completed" },
          { name: "Check your answers", link_enabled: false, status: "Completed" },
          { name: "DWP outcome", link_enabled: true, status: "Not started" },
        ]
      end

      # Note that this emulates the eventual ability of a user to go back to a completed task list item which
      # currently is not enabled as "Completed" items are not navigable from the "restrictive" task list.
      visit providers_legal_aid_application_applicant_details_path(@legal_aid_application)
      click_on "Save and continue"

      visit providers_legal_aid_application_task_list_path(@legal_aid_application)

      expect_section_with_task_list_items("Client and case details") do
        [
          { name: "Client details", link_enabled: false, status: "Completed" },
          { name: "Link to another application", link_enabled: false, status: "Completed" },
          { name: "Proceedings", link_enabled: false, status: "Completed" },
          { name: "Check your answers", link_enabled: true, status: "Review" },
          { name: "DWP outcome", link_enabled: false, status: "Not ready yet" },
        ]
      end

      within(section_list_for("Client and case details")) { click_link "Check your answers" }
      click_on "Save and continue"

      visit providers_legal_aid_application_task_list_path(@legal_aid_application)

      expect_section_with_task_list_items("Client and case details") do
        [
          { name: "Client details", link_enabled: false, status: "Completed" },
          { name: "Link to another application", link_enabled: false, status: "Completed" },
          { name: "Proceedings", link_enabled: false, status: "Completed" },
          { name: "Check your answers", link_enabled: false, status: "Completed" },
          { name: "DWP outcome", link_enabled: true, status: "Not started" },
        ]
      end
    end
  end
end
