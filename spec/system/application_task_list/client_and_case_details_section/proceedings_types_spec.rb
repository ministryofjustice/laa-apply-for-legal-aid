require "system_helper"

RSpec.describe "Proceedings types section", :vcr do
  feature "View the application task list" do
    before do
      login_as_a_provider

      Setting.setting.update!(linked_applications: true)
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
        ]
      end

      click_link "Link to another application"
      expect(page).to have_css("h1", text: "Do you want to link this application with another one?")

      govuk_choose("No")
      click_on "Save and continue"

      visit providers_legal_aid_application_task_list_path(@legal_aid_application)

      expect_section_with_task_list_items("Client and case details") do
        [
          { name: "Client details", link_enabled: false, status: "Completed" },
          { name: "Link to another application", link_enabled: false, status: "Completed" },
          { name: "Proceedings", link_enabled: true, status: "Not started" },
        ]
      end

      click_link "Proceedings"
      expect(page).to have_css("h1", text: "What does your client want legal aid for?")

      fill_in("proceeding-search-input", with: "se014")
      govuk_choose("Child arrangements order (CAO) - residence", match: :prefer_exact)
      click_on "Save and continue"

      expect(page).to have_css("h1", text: "You have added 1 proceeding")

      visit providers_legal_aid_application_task_list_path(@legal_aid_application)

      expect_section_with_task_list_items("Client and case details") do
        [
          { name: "Client details", link_enabled: false, status: "Completed" },
          { name: "Link to another application", link_enabled: false, status: "Completed" },
          { name: "Proceedings", link_enabled: true, status: "In progress" },
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
      govuk_fill_in_date_field(text: "Have you used delegated functions for this proceeding?", date: 5.days.ago)
      click_on "Save and continue"

      expect(page).to have_css("h2", text: "Do you want to use the default level of service and scope for the emergency application?")
      govuk_choose("No")
      click_on "Save and continue"

      expect(page).to have_css("h2", text: "For the emergency application, select the level of service")
      govuk_choose("Full Representation")
      click_on "Save and continue"

      expect(page).to have_css("h2", text: "Has the proceeding been listed for a final contested hearing?")
      govuk_choose("Yes")
      govuk_fill_in_date_field(text: "Has the proceeding been listed for a final contested hearing?", date: 5.days.from_now)
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
      govuk_fill_in_date_field(text: "Has the proceeding been listed for a final contested hearing?", date: 5.days.from_now)
      click_on "Save and continue"

      expect(page).to have_css("h2", text: "For the substantive application, select the scope")
      govuk_check("Blood Tests or DNA Tests")
      click_on "Save and continue"

      expect(page).to have_css("h2", text: "Do you want to request a higher emergency cost limit?")
      govuk_choose("Yes")
      fill_in("Enter a new emergency cost limit", with: "5000")
      fill_in("Tell us why you need a higher emergency cost limit", with: "Reasons")
      click_on "Save and continue"

      expect(page).to have_css("h1", text: "Does your client have a partner?")

      visit providers_legal_aid_application_task_list_path(@legal_aid_application)

      expect_section_with_task_list_items("Client and case details") do
        [
          { name: "Client details", link_enabled: false, status: "Completed" },
          { name: "Link to another application", link_enabled: false, status: "Completed" },
          { name: "Proceedings", link_enabled: false, status: "Completed" },
        ]
      end
    end
  end
end
