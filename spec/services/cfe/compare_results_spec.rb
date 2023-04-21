require "rails_helper"

RSpec.describe CFE::CompareResults do
  describe ".call" do
    subject(:call) { described_class.call }

    before do
      travel(-2.days) { create(:legal_aid_application, :with_cfe_v5_result) }
      travel(-12.hours) { create(:legal_aid_application, :with_cfe_v5_result) }
      travel(-6.hours) { create(:legal_aid_application, :with_cfe_v5_result) }
      allow(sub_builder).to receive(:cfe_result).and_return(fake_v6_result)
      allow(CFECivil::SubmissionBuilder).to receive(:call).and_return(sub_builder)
      allow(CFE::StoreCompareResult).to receive(:new).and_return(store_compare_result)
    end

    let(:fake_v6_result) { { version: "6", assessment: { id: "1234", submission_date: "1234" } }.to_json }
    let(:sub_builder) { instance_double(CFECivil::SubmissionBuilder) }
    let(:store_compare_result) { instance_double(CFE::StoreCompareResult, call: "something") }

    context "when run for the first time" do
      before do
        Setting.setting.update!(cfe_compare_run_at: nil)
      end

      it "only compares submissions from the last 24 hours" do
        expect(store_compare_result).to receive(:call).twice
        call
      end

      it "updates the setting run time" do
        call
        expect(Setting.setting.cfe_compare_run_at).not_to be_nil
      end
    end

    context "when run a subsequent time" do
      before do
        Setting.setting.update!(cfe_compare_run_at: 7.hours.ago)
      end

      it "only compares submissions since the last run" do
        expect(store_compare_result).to receive(:call).once
        call
      end
    end
  end
end
