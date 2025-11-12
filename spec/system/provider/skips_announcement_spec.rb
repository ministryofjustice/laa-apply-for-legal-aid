require "system_helper"

RSpec.describe "A provider can skip announcements" do
  feature "View the application task list" do
    before do
      Announcement.create!(display_type: :moj, body: "New working hours have been implemented 7am to 7pm", start_at: Time.zone.parse("9:00") - 1.day, end_at: Time.zone.parse("9:00") + 1.day)
      login_as_a_provider
    end

    let(:announcement) { Announcement.find_by(body: "New working hours have been implemented 7am to 7pm") }

    context "when an undismissed announcement exists" do
      let(:in_progress_path) { in_progress_providers_legal_aid_applications_path }

      scenario "it can be dismissed" do
        visit in_progress_path
        expect(page)
          .to have_css("h1", text: "Your applications")
          .and have_css(".moj-alert__content", text: "New working hours have been implemented 7am to 7pm")
          .and have_link(text: "Dismiss", href: v1_dismiss_announcements_path(params: { id: announcement.id, return_to: in_progress_path }))

        click_on "Dismiss"
        expect(page)
          .to have_css("h1", text: "Your applications")
          .and have_no_css(".moj-alert__content", text: "New working hours have been implemented 7am to 7pm")
      end
    end
  end
end
