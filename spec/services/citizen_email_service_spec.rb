require "rails_helper"

RSpec.describe CitizenEmailService do
  include Rails.application.routes.url_helpers

  let(:legal_aid_application) do
    create(
      :legal_aid_application,
      applicant:,
      provider: build(:provider, firm: build(:firm, name: "Test Firm")),
    )
  end

  let(:applicant) do
    build(
      :applicant,
      first_name: "John",
      last_name: "Doe",
      email: "test@example.com",
    )
  end

  describe "#send_email" do
    subject(:send_email) { described_class.new(legal_aid_application).send_email }

    before do
      allow(SecureRandom).to receive(:uuid).and_return("test-citizen-token")
      legal_aid_application.generate_citizen_access_token!
    end

    it "sends an email" do
      expect(ScheduledMailing).to receive(:send_now!).with(
        mailer_klass: NotifyMailer,
        mailer_method: :citizen_start_email,
        legal_aid_application_id: legal_aid_application.id,
        addressee: "test@example.com",
        arguments: [
          legal_aid_application.application_ref,
          "test@example.com",
          citizens_legal_aid_application_url("test-citizen-token"),
          "John Doe",
          "Test Firm",
        ],
      )

      send_email
    end
  end
end
