require "rails_helper"

RSpec.describe DWPOutcomeHelper do
  let(:application) { create(:legal_aid_application) }

  describe "#reset_confirm_dwp_status" do
    subject(:call_method) { helper.reset_confirm_dwp_status!(application) }

    before { call_method }

    let(:application) { create(:legal_aid_application, dwp_result_confirmed: true) }

    it "resets dwp_result_confirmed to nil" do
      expect(application.dwp_result_confirmed).to be_nil
    end
  end

  describe "#checking_dwp_status" do
    subject(:call_method) { helper.checking_dwp_status!(application) }

    before { call_method }

    it "updates dwp_result_confirmed to false" do
      expect(application.dwp_result_confirmed).to be false
    end
  end

  describe "#confirm_dwp_status_correct" do
    subject(:call_method) { helper.confirm_dwp_status_correct!(application) }

    before { call_method }

    it "updates dwp_result_confirmed to true" do
      expect(application.dwp_result_confirmed).to be true
    end
  end
end
