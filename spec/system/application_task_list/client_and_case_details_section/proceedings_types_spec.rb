require "system_helper"

RSpec.describe "Proceedings types section", :vcr do
  feature "View the application task list" do
    before do
      login_as_a_provider
    end

    # TODO: we navigate to the task list directly in this system spec but eventually we should be navigating using the on-screen button
    # "Save and go to task list" or similar.
    #

    scenario "I can complete the task list's Proceedings item" do
      fill_in_client_and_case_details_until_step(:link_application)

      @legal_aid_application ||= LegalAidApplication.find(id_from_current_page_url)
      visit providers_legal_aid_application_task_list_path(@legal_aid_application)

      expect_section_with_task_list_items("Client and case details") do
        [
          { name: "Client details", link_enabled: false, status: "Completed" },
          { name: "Link to another application", link_enabled: true, status: "Not started" },
          { name: "Proceedings", link_enabled: false, status: "Cannot start yet" },
          { name: "Check your answers", link_enabled: false, status: "Not ready yet" },
          { name: "DWP outcome", link_enabled: false, status: "Not ready yet" },
        ]
      end

      click_link "Link to another application"
      expect(page).to have_css("h1", text: "Linking cases")

      govuk_choose("No")
      click_on "Save and continue"

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

      click_link "Proceedings"
      expect(page).to have_css("h1", text: "What does your client want legal aid for?")

      fill_in("proceeding-search-input", with: "se014")
      sleep(2)
      govuk_choose("Child arrangements order (CAO) - residence", match: :prefer_exact)
      click_on "Save and continue"

      expect(page).to have_css("h1", text: "You have added 1 proceeding")

      visit providers_legal_aid_application_task_list_path(@legal_aid_application)

      expect_section_with_task_list_items("Client and case details") do
        [
          { name: "Client details", link_enabled: false, status: "Completed" },
          { name: "Link to another application", link_enabled: false, status: "Completed" },
          { name: "Proceedings", link_enabled: true, status: "In progress" },
          { name: "Check your answers", link_enabled: false, status: "Not ready yet" },
          { name: "DWP outcome", link_enabled: false, status: "Not ready yet" },
        ]
      end

      click_link "Proceedings"
      expect(page).to have_css("h1", text: "You have added 1 proceeding")

      govuk_choose("No")
      click_on "Save and continue"

      expect(page).to have_css("h2", text: "What is your client's role in this proceeding?")
      govuk_choose("Applicant, claimant or petitioner")
      click_on "Save and continue"

      expect(page).to have_css("h2", text: "Have you used delegated functions for this proceeding?")
      govuk_choose("Yes")
      fill_in "Date you used delegated functions", with: 5.days.ago.to_date.to_s(:date_picker)
      click_on "Save and continue"

      expect(page).to have_css("h2", text: "Do you want to use the default level of service and scope for the emergency application?")
      govuk_choose("No")
      click_on "Save and continue"

      expect(page).to have_css("h2", text: "For the emergency application, select the level of service")
      govuk_choose("Full Representation")
      click_on "Save and continue"

      expect(page).to have_css("h2", text: "Has the proceeding been listed for a final contested hearing?")
      govuk_choose("Yes")
      fill_in "When is the hearing?", with: 5.days.ago.to_date.to_s(:date_picker)
      click_on "Save and continue"

      expect(page).to have_css("h2", text: "For the emergency application, select the scope")
      govuk_check("Blood Tests or DNA Tests")
      click_on "Save and continue"

      expect(page).to have_css("h2", text: "Do you want to use the default level of service and scope for the substantive application?")
      govuk_choose("No")
      click_on "Save and continue"

      expect(page).to have_css("h2", text: "For the substantive application, select the level of service")
      govuk_choose("Full Representation")
      click_on "Save and continue"

      expect(page).to have_css("h2", text: "Has the proceeding been listed for a final contested hearing?")
      govuk_choose("Yes")
      fill_in "When is the hearing?", with: 5.days.ago.to_date.to_s(:date_picker)
      click_on "Save and continue"

      expect(page).to have_css("h2", text: "For the substantive application, select the scope")
      govuk_check("Blood Tests or DNA Tests")
      click_on "Save and continue"

      expect(page).to have_css("h2", text: "Do you want to request a higher emergency cost limit?")
      govuk_choose("Yes")
      fill_in("Enter a new emergency cost limit", with: "5000")
      fill_in("Tell us why you need a higher emergency cost limit", with: "Reasons")
      click_on "Save and continue"

      expect(page).to have_css("h1", text: "Your client's partner")

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
    end
  end
end
