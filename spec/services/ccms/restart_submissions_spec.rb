require "rails_helper"

RSpec.describe CCMS::RestartSubmissions do
  subject(:restart_submissions) { described_class.call }

  before do
    allow(Rails.configuration.x.ccms_soa).to receive(:submit_applications_to_ccms).and_return(true)
    allow(Setting).to receive(:enable_ccms_submission?).and_return(true)
  end

  context "when no submissions are paused" do
    it { is_expected.to eql "No paused submissions found" }
  end

  context "when two applications are paused" do
    before do
      create_list(:legal_aid_application, 2, :submission_paused)
    end

    it { is_expected.to eql "2 CCMS submissions restarted" }

    it "changes the states to submitting_assessment" do
      restart_submissions
      expect(LegalAidApplication.first.reload.state).to eql "generating_reports"
      expect(LegalAidApplication.last.reload.state).to eql "generating_reports"
    end
  end
end
