require "rails_helper"

RSpec.describe Flow::Steps::ProviderDWP::DWPResultsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_dwp_result_path(legal_aid_application) }
  end

  describe "#forward" do
    subject(:forward_step) { described_class.forward.call(legal_aid_application) }

    let(:legal_aid_application) do
      create(:legal_aid_application, :with_proceedings).tap do |application|
        application.benefit_check_result = benefit_check_result
      end
    end

    context "with unsuccessful benefit check status" do
      let(:benefit_check_result) { nil }

      it { is_expected.to eq :dwp_fallback }
    end

    context "with positive benefit check status and used delegated funtions" do
      let(:benefit_check_result) { build(:benefit_check_result, result: "Yes") }

      before do
        legal_aid_application
          .proceedings
          .first
          .update!(used_delegated_functions: true,
                   used_delegated_functions_on: 1.week.ago,
                   used_delegated_functions_reported_on: 1.week.ago)

        legal_aid_application.reload
      end

      it { is_expected.to eq :substantive_applications }

      it "changes/leaves state machine to/as Passported" do
        expect { forward_step }
          .not_to change { legal_aid_application.reload.state_machine.type }
            .from("PassportedStateMachine")
      end
    end

    context "with positive benefit check status and did NOT use delegated funtions" do
      let(:benefit_check_result) { build(:benefit_check_result, result: "Yes") }

      it { is_expected.to eq :capital_introductions }

      it "changes/leaves state machine to/as Passported" do
        expect { forward_step }
          .not_to change { legal_aid_application.reload.state_machine.type }
            .from("PassportedStateMachine")
      end
    end

    context "with negative benefit check status" do
      let(:benefit_check_result) { build(:benefit_check_result, result: "No") }

      it { is_expected.to eq :about_financial_means }

      it "changes state machine to Passported" do
        expect { forward_step }
          .to change { legal_aid_application.reload.state_machine.type }
            .from("PassportedStateMachine")
            .to("NonPassportedStateMachine")
      end
    end
  end
end
