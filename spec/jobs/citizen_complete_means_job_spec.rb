require "rails_helper"

RSpec.describe CitizenCompleteMeansJob, :vcr do
  subject(:citizen_complete_means_job) { described_class.new.perform(legal_aid_application.id) }

  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine, :applicant_entering_means) }
  let!(:scheduled_mail) { create(:scheduled_mailing, :citizen_financial_reminder, legal_aid_application:) }
  let!(:scheduled_mail2) { create(:scheduled_mailing, :citizen_financial_reminder, legal_aid_application:) }

  describe "cancelling emails" do
    it "calls cancel on the scheduled emails" do
      citizen_complete_means_job
      expect(scheduled_mail.reload.cancelled_at).not_to be_nil
      expect(scheduled_mail2.reload.cancelled_at).not_to be_nil
    end
  end

  describe "SubmitProviderReminderService" do
    it "sends a reminder mail" do
      service = instance_double SubmitProviderReminderService
      allow(SubmitProviderReminderService).to receive(:new).and_return(service)
      expect(service).to receive(:send_email)
      citizen_complete_means_job
    end
  end
end
