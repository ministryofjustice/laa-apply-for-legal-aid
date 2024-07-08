require "rails_helper"

RSpec.describe Flow::Steps::ProviderDWPOverride::ConfirmDWPNonPassportedApplicationsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_confirm_dwp_non_passported_applications_path(legal_aid_application) }
  end

  describe "#forward" do
    subject(:forward_step) { described_class.forward.call(legal_aid_application, confirm_dwp_non_passported) }

    context "when the user sends true" do
      let(:confirm_dwp_non_passported) { true }

      it { is_expected.to eq :about_financial_means }

      it "sets the state machine" do
        forward_step
        expect(legal_aid_application.state_machine.type).to eq "NonPassportedStateMachine"
      end
    end

    context "when the user sends false" do
      let(:confirm_dwp_non_passported) { false }

      it { is_expected.to eq :check_client_details }

      it "sets the state machine" do
        forward_step
        expect(legal_aid_application.state_machine.type).to eq "PassportedStateMachine"
      end
    end
  end
end
