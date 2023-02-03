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

  describe "#provider_assess_means!" do
    subject(:event) { legal_aid_application.provider_assess_means! }

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

    context "when from state checking_means_income" do
      let(:legal_aid_application) { create(:legal_aid_application, :checking_means_income) }

      it "sets state to provider_assessing_means" do
        expect { event }.to change(legal_aid_application, :state)
                              .from("checking_means_income")
                              .to("provider_assessing_means")
      end
    end
  end

  describe "#check_means_income!" do
    subject(:event) { legal_aid_application.check_means_income! }

    context "when from state provider_assessing_means" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_non_passported_state_machine, :provider_assessing_means) }

      it "sets state to checking_means_income" do
        expect { event }.to change(legal_aid_application, :state)
                              .from("provider_assessing_means")
                              .to("checking_means_income")
      end
    end
  end
end
