require "rails_helper"
require "sidekiq/testing"

RSpec.describe SubmitProviderReminderService, :vcr do
  subject { described_class.new(application) }

  let(:provider) { create(:provider, email: "test@example.com") }
  let(:application) { create(:application, :with_applicant, provider:) }
  let(:application_url) { "http://test.com" }

  describe "#send_email" do
    it "creates two scheduled mailing records" do
      expect { subject.send_email }.to change(ScheduledMailing, :count).by(1)
    end

    context "sending the email" do
      let(:mail) { SubmitProviderFinancialReminderMailer.notify_provider(application.id, application_url) }

      it "sends an email with the right parameters" do
        expect(mail.govuk_notify_personalisation).to eq(
          application_url:,
          ref_number: application.application_ref,
          client_name: application.applicant.full_name,
        )
      end
    end
  end
end
