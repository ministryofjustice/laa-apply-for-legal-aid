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
    let(:laa1) { create(:legal_aid_application, :submission_paused, created_at: 3.days.ago, merits_submitted_at: 2.days.ago, application_ref: "AAA111") }
    let(:laa2) { create(:legal_aid_application, :submission_paused, created_at: 4.days.ago, merits_submitted_at: 1.day.ago, application_ref: "BBB222") }

    before do
      laa1
      laa2
    end

    it { is_expected.to eql "2 CCMS submissions restarted" }

    it "changes the states to submitting_assessment" do
      expect { restart_submissions }.to change { laa1.reload.state }.from("submission_paused").to("generating_reports")
      expect(laa2.reload.state).to eql "generating_reports"
    end

    it "processes the earliest submitted application first (despite being created later)" do
      restart_submissions
      expect(laa1.updated_at).to be < laa2.updated_at
    end
  end
end
