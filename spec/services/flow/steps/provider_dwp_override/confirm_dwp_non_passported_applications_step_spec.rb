require "rails_helper"

RSpec.describe Flow::Steps::ProviderDWPOverride::ConfirmDWPNonPassportedApplicationsStep do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:has_benefit) { true }
  let(:args) { has_benefit }

  context "when the provider confirms the application is non passported" do
    it "has expected flow step" do
      expect(described_class).to have_flow_step_args(path: "/providers/applications/#{legal_aid_application.id}/confirm_dwp_non_passported_applications?locale=en",
                                                     forward: :about_financial_means,
                                                     check_answers: nil)
    end

    it "sets the application's state machine to be the passported state machine when forward is called" do
      described_class.forward.call(legal_aid_application, args)
      expect(legal_aid_application.state_machine_proxy.type).to eq "NonPassportedStateMachine"
    end
  end

  context "when the provider confirms the application is passported" do
    let(:has_benefit) { false }

    it "has expected flow step" do
      expect(described_class).to have_flow_step_args(path: "/providers/applications/#{legal_aid_application.id}/confirm_dwp_non_passported_applications?locale=en",
                                                     forward: :check_client_details,
                                                     check_answers: nil)
    end

    it "sets the application's state machine to be the non passported state machine when forward is called" do
      described_class.forward.call(legal_aid_application, args)
      expect(legal_aid_application.state_machine_proxy.type).to eq "PassportedStateMachine"
    end
  end
end
