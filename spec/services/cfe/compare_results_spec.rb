require "rails_helper"

RSpec.describe CFE::CompareResults do
  describe ".call" do
    subject(:call) { described_class.call }

    before do
      travel(-2.days) { create(:legal_aid_application, :with_cfe_v5_result_obtained, transaction_period_finish_on: 5.days.ago) }
      travel(-12.hours) { create(:legal_aid_application, :with_cfe_v5_result_obtained, transaction_period_finish_on: 5.days.ago) }
      travel(-6.hours) { create(:legal_aid_application, :with_cfe_v5_result_obtained, transaction_period_finish_on: 5.days.ago) }
      allow(sub_builder).to receive(:cfe_result).and_return(fake_v6_result)
      allow(sub_builder).to receive(:request_body).and_return({})
      allow(CFECivil::SubmissionBuilder).to receive(:new).and_return(sub_builder)
      allow(CFE::StoreCompareResult).to receive(:new).and_return(store_compare_result)
      allow(CFE::ResetGoogleSheetFilter).to receive(:call).and_return(true)
    end

    let(:fake_v6_result) { file_fixture("cfe_civil_comparison/v6/compare_result.json").read }
    let(:sub_builder) { instance_double(CFECivil::SubmissionBuilder, call: true) }
    let(:store_compare_result) { instance_double(CFE::StoreCompareResult, call: "something") }

    context "when run for the first time" do
      before do
        Setting.setting.update!(cfe_compare_run_at: nil)
      end

      it "only compares submissions created in the last 24 hours" do
        # this ignores the submission created -2.days ago, but includes those from -12 & -6 hours
        expect(store_compare_result).to receive(:call).twice
        call
      end

      it "updates the setting run time" do
        expect { call }.to change { Setting.setting.cfe_compare_run_at }.from(nil).to(instance_of(ActiveSupport::TimeWithZone))
      end
    end

    context "when run a subsequent time" do
      before do
        Setting.setting.update!(cfe_compare_run_at: 7.hours.ago)
      end

      it "only compares submissions since the last run" do
        # only expect the application created 6 hours ago
        expect(store_compare_result).to receive(:call).once
        call
      end
    end
  end
end
