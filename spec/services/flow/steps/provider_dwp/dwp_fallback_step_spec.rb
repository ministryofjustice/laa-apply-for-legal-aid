require "rails_helper"

RSpec.describe Flow::Steps::ProviderDWP::DWPFallbackStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_dwp_fallback_path(legal_aid_application) }
  end

  describe "#forward" do
    subject(:forward_step) { described_class.forward.call(legal_aid_application, confirm_receipt_of_benefit) }

    context "when the provider says a benefit is received" do
      let(:confirm_receipt_of_benefit) { true }

      it { is_expected.to eq :received_benefit_confirmations }

      it "sets the state machine" do
        forward_step
        expect(legal_aid_application.state_machine.type).to eq "PassportedStateMachine"
      end
    end

    context "when the provider says a benefit is not received" do
      let(:confirm_receipt_of_benefit) { false }

      it { is_expected.to eq :about_financial_means }

      it "sets the state machine" do
        forward_step
        expect(legal_aid_application.state_machine.type).to eq "NonPassportedStateMachine"
      end
    end
  end
end
