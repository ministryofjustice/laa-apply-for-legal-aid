require "rails_helper"

RSpec.describe CCMS::RestartSubmissionWorker do
  describe "#perform" do
    subject(:perform) { described_class.new.perform(legal_aid_application.id) }

    let(:legal_aid_application) { instance_double(LegalAidApplication, id: "TEST-1234", restart_submission!: "triggered") }

    before { allow(LegalAidApplication).to receive(:find).with("TEST-1234").and_return legal_aid_application }

    it "sends a restart_submission! message to a legal_aid_application" do
      perform
      expect(legal_aid_application).to have_received(:restart_submission!).once
    end
  end
end
