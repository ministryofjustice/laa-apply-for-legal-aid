require "rails_helper"

RSpec.describe Flow::Steps::ProviderDWPOverride::HasEvidenceOfBenefitsStep do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject(:path) { described_class.path.call(legal_aid_application) }

    it "returns the has_evidence_of_benefit_path when called" do
      expect(path).to eq "/providers/applications/#{legal_aid_application.id}/has_evidence_of_benefit?locale=en"
    end
  end

  describe "#forward" do
    subject(:forward) { described_class.forward.call(legal_aid_application, has_evidence_of_benefits) }

    let(:has_evidence_of_benefits) { true }

    context "when the provider has evidence that the applicant receives passported bemefits" do
      context "when the provider has used delegated functions for the application" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, :with_delegated_functions_on_proceedings, explicit_proceedings: [:da004], set_lead_proceeding: :da004, df_options: { DA004: [Time.zone.today, Time.zone.today] }) }

        it "returns the substantive_applications step when called" do
          expect(forward).to eq(:substantive_applications)
        end

        it "sets the application's state machine to be the passported state machine" do
          forward
          expect(legal_aid_application.state_machine_proxy.type).to eq "PassportedStateMachine"
        end
      end

      context "when the provider has not used delegated functions for the application" do
        it "returns the capital_introductions step when called" do
          expect(forward).to eq(:capital_introductions)
        end

        it "sets the application's state machine to be the passported state machine" do
          forward
          expect(legal_aid_application.state_machine_proxy.type).to eq "PassportedStateMachine"
        end
      end
    end

    context "when the provider does not have evidence that the applicant receives passported bemefits" do
      let(:has_evidence_of_benefits) { false }

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
