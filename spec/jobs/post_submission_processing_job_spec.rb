require "rails_helper"

RSpec.describe PostSubmissionProcessingJob do
  subject(:psp_job) { described_class.new.perform(application.id, feedback_url) }

  let(:application) { create(:legal_aid_application) }
  let(:feedback_url) { "www.example.com/feedback/new" }

  describe "SubmissionConfirmationMailer" do
    it "schedules an email for immediate delivery" do
      expect { psp_job }.to change(ScheduledMailing, :count).by(1)
      rec = ScheduledMailing.first

      expect(rec.mailer_klass).to eq "SubmissionConfirmationMailer"
      expect(rec.mailer_method).to eq "notify"
      expect(rec.legal_aid_application_id).to eq application.id
      expect(rec.addressee).to eq application.provider.email
      expect(rec.arguments).to eq [application.id, feedback_url]
      expect(rec.scheduled_at).to have_been_in_the_past
    end
  end
end
