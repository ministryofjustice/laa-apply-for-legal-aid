require "rails_helper"

RSpec.describe SubmitCitizenReminderService do
  include Rails.application.routes.url_helpers

  let(:legal_aid_application) { create(:legal_aid_application, applicant:) }

  let(:applicant) do
    build(
      :applicant,
      first_name: "Test",
      last_name: "User",
      email: "test@example.com",
    )
  end

  describe "#send_email" do
    subject(:send_email) { described_class.new(legal_aid_application).send_email }

    before do
      allow(ScheduledMailing).to receive(:send_later!)
      allow(SecureRandom).to receive(:uuid).and_return("test-citizen-token")
      travel_to Date.new(2025, 1, 1)
      legal_aid_application.generate_citizen_access_token!
    end

    it "schedules two emails" do
      send_email

      [1.day.from_now, 7.days.from_now].each do |date|
        expect(ScheduledMailing).to have_received(:send_later!).with(
          mailer_klass: SubmitCitizenFinancialReminderMailer,
          mailer_method: :notify_citizen,
          legal_aid_application_id: legal_aid_application.id,
          addressee: "test@example.com",
          scheduled_at: date.change(hour: 9),
          arguments: [
            legal_aid_application.id,
            "test@example.com",
            citizens_legal_aid_application_url("test-citizen-token"),
            "Test User",
            "8 January 2025",
          ],
        )
      end
    end
  end
end
