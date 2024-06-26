require "rails_helper"
require "sidekiq/testing"

RSpec.describe ProviderEmailService do
  subject(:provider_email_service) { described_class.new(application) }

  let(:applicant) { create(:applicant, first_name: "John", last_name: "Doe") }
  let(:provider) { create(:provider, email: "test@example.com") }
  let(:application) { create(:application, applicant:, provider:) }
  let(:application_url) { "http://www.example.com/providers/applications/#{application.id}/client_completed_means?locale=en" }

  describe "#send_email" do
    let(:mailer_args) do
      [
        application.id,
        provider.name,
        applicant.full_name,
        provider.email,
      ]
    end

    it "schedules a mail for immediate delivery" do
      expect { provider_email_service.send_email }.to change(ScheduledMailing, :count).by(1)

      rec = ScheduledMailing.first
      expect(rec.legal_aid_application_id).to eq application.id
      expect(rec.mailer_klass).to eq "CitizenCompletedMeansMailer"
      expect(rec.mailer_method).to eq "notify_provider"
      expect(rec.scheduled_at).to have_been_in_the_past
      expect(rec.status).to eq "waiting"
      expect(rec.addressee).to eq provider.email
    end
  end
end
