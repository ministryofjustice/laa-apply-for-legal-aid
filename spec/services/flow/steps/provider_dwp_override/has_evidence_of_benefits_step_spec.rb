require "rails_helper"

RSpec.describe Flow::Steps::ProviderDWPOverride::HasEvidenceOfBenefitsStep do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:has_evidence_of_benefits) { true }
  let(:args) { has_evidence_of_benefits }

  context "when the provider has evidence that the applicant receives passported benefits" do
    context "when the provider has used delegated functions" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, :with_delegated_functions_on_proceedings, explicit_proceedings: [:da004], set_lead_proceeding: :da004, df_options: { DA004: [Time.zone.today, Time.zone.today] }) }

      it "has expected flow step" do
        expect(described_class).to have_flow_step_args(path: "/providers/applications/#{legal_aid_application.id}/has_evidence_of_benefit?locale=en",
                                                       forward: :substantive_applications,
                                                       check_answers: nil)
      end

      it "sets the application's state machine to be the passported state machine when forward is called" do
        described_class.forward.call(legal_aid_application, args)
        expect(legal_aid_application.state_machine_proxy.type).to eq "PassportedStateMachine"
      end
    end

    context "when the provider has not used delegated functions" do
      it "has expected flow step" do
        expect(described_class).to have_flow_step_args(path: "/providers/applications/#{legal_aid_application.id}/has_evidence_of_benefit?locale=en",
                                                       forward: :capital_introductions,
                                                       check_answers: nil)
      end

      it "sets the application's state machine to be the passported state machine when forward is called" do
        described_class.forward.call(legal_aid_application, args)
        expect(legal_aid_application.state_machine_proxy.type).to eq "PassportedStateMachine"
      end
    end
  end

  context "when the provider does not have evidence that the applicant receives passported bemefits" do
    let(:has_evidence_of_benefits) { false }

    it "has expected flow step" do
      expect(described_class).to have_flow_step_args(path: "/providers/applications/#{legal_aid_application.id}/has_evidence_of_benefit?locale=en",
                                                     forward: :about_financial_means,
                                                     check_answers: nil)
    end

    it "sets the application's state machine to be the non passported state machine when forward is called" do
      described_class.forward.call(legal_aid_application, args)
      expect(legal_aid_application.state_machine_proxy.type).to eq "NonPassportedStateMachine"
    end
  end
end
