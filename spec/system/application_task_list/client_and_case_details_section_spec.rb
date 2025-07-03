require "system_helper"

RSpec.describe "Client and case details section", :vcr do
  feature "View the application task list" do
    before do
      login_as_a_provider
    end

    scenario "I can complete the task list's Client details item" do
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
      @legal_aid_application ||= LegalAidApplication.find(id_from_current_page_url)
      visit providers_legal_aid_application_task_list_path(@legal_aid_application)

      rows = [
        { name: "Client details", linked_enabled: true, status: "In progress" },
      ]

      within(section_list_for("Client and case details")) do
        rows.each do |row|
          expect(page).to have_css(".govuk-task-list__name-and-hint", text: row[:name])
          expect(page).to have_link(row[:name]) if row[:link_enabled] == true
          expect(page).to have_css(".govuk-task-list__status", text: row[:status])
        end
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
      expect(page).to have_css("h1", text: "What does your client want legal aid for?")

      visit providers_legal_aid_application_task_list_path(@legal_aid_application)

      rows = [
        { name: "Client details", linked_enabled: false, status: "Completed" },
      ]

      within(section_list_for("Client and case details")) do
        rows.each do |row|
          expect(page).to have_css(".govuk-task-list__name-and-hint", text: row[:name])
          expect(page).to have_link(row[:name]) if row[:link_enabled] == true
          expect(page).to have_css(".govuk-task-list__status", text: row[:status])
        end
      end
    end
  end
end
