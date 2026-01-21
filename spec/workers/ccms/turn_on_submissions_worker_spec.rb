require "rails_helper"

RSpec.describe CCMS::TurnOnSubmissionsWorker do
  describe ".perform" do
    subject(:perform) { described_class.new.perform }

    before do
      allow(Rails.logger).to receive(:info)
      allow(CCMS::RestartSubmissionWorker).to receive(:perform_in).and_return("started")
    end

    context "when no submissions are paused" do
      it "sends the expected message to rails logger" do
        perform
        expect(Rails.logger).to have_received(:info).with("CCMS::RestartSubmissionsWorker - No paused submissions found")
      end
    end

    context "when two applications are paused" do
      before do
        create(:legal_aid_application, :submission_paused, created_at: 3.days.ago, merits_submitted_at: 2.days.ago, application_ref: "AAA111")
        create(:legal_aid_application, :submission_paused, created_at: 4.days.ago, merits_submitted_at: 1.day.ago, application_ref: "BBB222")
      end

      it "calls the RestartSubmissionWorker twice" do
        perform
        expect(CCMS::RestartSubmissionWorker).to have_received(:perform_in).twice
      end

      it "sends the expected messages to rails logger" do
        perform
        expect(Rails.logger).to have_received(:info).with("CCMS::RestartSubmissionsWorker - 2 submissions to restart, expected to take 00:00:10")
        expect(Rails.logger).to have_received(:info).with("CCMS::RestartSubmissionsWorker - all submissions restarted")
      end
    end
  end
end
