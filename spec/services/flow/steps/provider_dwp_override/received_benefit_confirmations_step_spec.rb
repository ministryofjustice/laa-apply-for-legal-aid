require "rails_helper"

RSpec.describe Flow::Steps::ProviderDWPOverride::ReceivedBenefitConfirmationsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_received_benefit_confirmation_path(legal_aid_application) }
  end

  describe "#forward" do
    subject(:forward_step) { described_class.forward.call(legal_aid_application, has_benefit) }

    context "when the user sends true" do
      let(:has_benefit) { true }

      it { is_expected.to eq :has_evidence_of_benefits }

      it "sets the state machine" do
        forward_step
        expect(legal_aid_application.state_machine.type).to eq "PassportedStateMachine"
      end
    end

    context "when the user sends false" do
      let(:has_benefit) { false }

      it { is_expected.to eq :about_financial_means }

      it "sets the state machine" do
        forward_step
        expect(legal_aid_application.state_machine.type).to eq "NonPassportedStateMachine"
      end
    end
  end
end
