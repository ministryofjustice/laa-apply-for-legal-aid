require "rails_helper"

RSpec.describe Flow::Steps::ProviderDWPOverride::HasEvidenceOfBenefitsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_has_evidence_of_benefit_path(legal_aid_application) }
  end

  describe "#forward" do
    subject(:forward_step) { described_class.forward.call(legal_aid_application, has_evidence_of_benefit) }

    context "when there is evidence of the benefit" do
      before { allow(legal_aid_application).to receive(:used_delegated_functions?).and_return(used_delegated_functions) }

      let(:has_evidence_of_benefit) { true }
      let(:used_delegated_functions) { true }

      it "sets the state machine" do
        forward_step
        expect(legal_aid_application.state_machine.type).to eq "PassportedStateMachine"
      end

      context "and the application uses delegated functions" do
        it { is_expected.to eq :substantive_applications }
      end

      context "and the application does not use delegated functions" do
        let(:used_delegated_functions) { false }

        it { is_expected.to eq :capital_introductions }
      end
    end

    context "when there is no evidence of the benefit" do
      let(:has_evidence_of_benefit) { false }

      it { is_expected.to eq :about_financial_means }

      it "sets the state machine" do
        forward_step
        expect(legal_aid_application.state_machine.type).to eq "NonPassportedStateMachine"
      end
    end
  end
end
