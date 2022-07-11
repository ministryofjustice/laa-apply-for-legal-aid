require "rails_helper"

RSpec.describe NonPassportedStateMachine do
  describe "#applicant_enter_means!" do
    subject(:event) { legal_aid_application.applicant_enter_means! }

    let(:legal_aid_application) { create(:legal_aid_application, :use_ccms_offline_accounts) }

    it "sets state to provider_entering_means" do
      expect { event }.to change(legal_aid_application, :state).from("use_ccms").to("applicant_entering_means")
    end

    it "sets the ccms_reason to nil" do
      expect { event }.to change(legal_aid_application, :ccms_reason).from("offline_accounts").to(nil)
    end
  end

  describe "#open_banking_not_selected!" do
    subject(:event) { legal_aid_application.open_banking_not_selected! }

    context "when from state provider_confirming_applicant_eligibility" do
      let(:legal_aid_application) { create(:legal_aid_application, :provider_confirming_applicant_eligibility) }

      it "sets state to provider_assessing_means" do
        expect { event }.to change(legal_aid_application, :state)
                              .from("provider_confirming_applicant_eligibility")
                              .to("provider_assessing_means")
      end
    end

    context "when from state checking_non_passported_means" do
      let(:legal_aid_application) { create(:legal_aid_application, :checking_non_passported_means) }

      it "sets state to provider_assessing_means" do
        expect { event }.to change(legal_aid_application, :state)
                              .from("checking_non_passported_means")
                              .to("provider_assessing_means")
      end
    end
  end
end
