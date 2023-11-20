require "rails_helper"

RSpec.describe Flow::Steps::ReceivedBenefitConfirmationsStep do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject(:path) { described_class.path.call(legal_aid_application) }

    it "returns the received_benefits_confirmations_path when called" do
      expect(path).to eq "/providers/applications/#{legal_aid_application.id}/received_benefit_confirmation?locale=en"
    end
  end

  describe "#forward" do
    subject(:forward) { described_class.forward.call(legal_aid_application, has_benefit) }

    let(:has_benefit) { true }

    context "when the provider confirms the applicant is in receipt of passported benefit" do
      it "returns the has_evidence_of_benefits step when called" do
        expect(forward).to eq(:has_evidence_of_benefits)
      end

      it "sets the application's state machine to be the passported state machine" do
        forward
        expect(legal_aid_application.state_machine_proxy.type).to eq "PassportedStateMachine"
      end
    end

    context "when the provider confirms the application is passported" do
      let(:has_benefit) { false }

      it "returns the about_financial_means step when called" do
        expect(forward).to eq(:about_financial_means)
      end

      it "sets the application's state machine to be the non passported state machine" do
        forward
        expect(legal_aid_application.state_machine_proxy.type).to eq "NonPassportedStateMachine"
      end
    end
  end

  describe "#check_answers" do
    subject(:check_answers) { described_class.check_answers }

    it "returns nil" do
      expect(check_answers).to be_nil
    end
  end
end
