require "rails_helper"

RSpec.describe Flow::Steps::ProviderDWPOverride::ConfirmDWPNonPassportedApplicationsStep do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject(:path) { described_class.path.call(legal_aid_application) }

    it "returns the confirm_dwp_non_passported_path when called" do
      expect(path).to eq "/providers/applications/#{legal_aid_application.id}/confirm_dwp_non_passported_applications?locale=en"
    end
  end

  describe "#forward" do
    subject(:forward) { described_class.forward.call(legal_aid_application, confirm_dwp_non_passported) }

    let(:confirm_dwp_non_passported) { true }

    context "when the provider confirms the application is non passported" do
      it "returns the about_financial_means step when called" do
        expect(forward).to eq(:about_financial_means)
      end

      it "sets the application's state machine to be the non passported state machine" do
        forward
        expect(legal_aid_application.state_machine_proxy.type).to eq "NonPassportedStateMachine"
      end
    end

    context "when the provider confirms the application is passported" do
      let(:confirm_dwp_non_passported) { false }

      it "returns the check_client_details step when called" do
        expect(forward).to eq(:check_client_details)
      end

      it "sets the application's state machine to be the passported state machine" do
        forward
        expect(legal_aid_application.state_machine_proxy.type).to eq "PassportedStateMachine"
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
