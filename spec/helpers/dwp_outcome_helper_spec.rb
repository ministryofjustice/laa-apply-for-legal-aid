require "rails_helper"

RSpec.describe DWPOutcomeHelper do
  let(:application) { create(:legal_aid_application) }

  describe "#reset_confirm_dwp_status" do
    subject(:call_method) { helper.reset_confirm_dwp_status!(application) }

    before { call_method }

    let(:application) { create(:legal_aid_application, confirm_dwp_result: true) }

    it "resets confirm_dwp_result to nil" do
      expect(application.confirm_dwp_result).to be_nil
    end
  end

  describe "#update_confirm_dwp_result" do
    subject(:call_method) { helper.update_confirm_dwp_status!(application, true) }

    before { call_method }

    it "updates confirm_dwp_result to true" do
      expect(application.confirm_dwp_result).to be_truthy
    end
  end
end
