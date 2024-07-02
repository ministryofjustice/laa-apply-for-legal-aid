require "rails_helper"

RSpec.describe Flow::Steps::ProviderStart::CheckBenefitsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:dwp_override_non_passported) { false }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_check_benefits_path(legal_aid_application) }
  end

  describe "#forward" do
    subject(:forward_step) { described_class.forward.call(legal_aid_application, dwp_override_non_passported) }

    context "when the dwp returns that the applicant receives benefits" do
      before { allow(legal_aid_application).to receive(:applicant_receives_benefit?).and_return(true) }

      it "sets the state machine" do
        forward_step
        expect(legal_aid_application.state_machine.type).to eq "PassportedStateMachine"
      end

      context "when the provider has used delegated functions" do
        before { allow(legal_aid_application).to receive(:used_delegated_functions?).and_return(true) }

        it { is_expected.to eq :substantive_applications }
      end

      context "when the provider has not used delegated functions" do
        before { allow(legal_aid_application).to receive(:used_delegated_functions?).and_return(false) }

        it { is_expected.to eq :capital_introductions }
      end
    end

    context "when the dwp returns that the applicant does not receive benefits" do
      before { allow(legal_aid_application).to receive(:applicant_receives_benefit?).and_return(false) }

      it "sets the state machine" do
        forward_step
        expect(legal_aid_application.state_machine.type).to eq "NonPassportedStateMachine"
      end

      context "when the provider overrides the dwp result" do
        let(:dwp_override_non_passported) { true }

        it { is_expected.to eq :confirm_dwp_non_passported_applications }
      end

      context "when the provider does not override the dwp result" do
        it { is_expected.to eq :applicant_employed }
      end
    end
  end
end
