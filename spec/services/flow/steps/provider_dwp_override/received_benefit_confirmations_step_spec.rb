require "rails_helper"

RSpec.describe Flow::Steps::ProviderDWPOverride::ReceivedBenefitConfirmationsStep do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:has_benefit) { true }
  let(:args) { has_benefit }

  context "when the provider confirms the applicant is in receipt of passported benefit" do
    it "has expected flow step" do
      expect(described_class).to have_flow_step_args(path: "/providers/applications/#{legal_aid_application.id}/received_benefit_confirmation?locale=en",
                                                     forward: :has_evidence_of_benefits,
                                                     check_answers: nil)
    end

    it "sets the application's state machine to be the passported state machine when forward is called" do
      described_class.forward.call(legal_aid_application, args)
      expect(legal_aid_application.state_machine_proxy.type).to eq "PassportedStateMachine"
    end
  end

  context "when the provider confirms the applicant is not in receipt of passported benefit" do
    let(:has_benefit) { false }

    it "has expected flow step" do
      expect(described_class).to have_flow_step_args(path: "/providers/applications/#{legal_aid_application.id}/received_benefit_confirmation?locale=en",
                                                     forward: :about_financial_means,
                                                     check_answers: nil)
    end

    it "sets the application's state machine to be the non passported state machine when forward is called" do
      described_class.forward.call(legal_aid_application, args)
      expect(legal_aid_application.state_machine_proxy.type).to eq "NonPassportedStateMachine"
    end
  end
end
