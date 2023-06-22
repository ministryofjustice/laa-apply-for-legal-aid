require "rails_helper"

RSpec.describe CFE::CompareSubmission do
  describe ".call" do
    subject(:call) { described_class.call(legal_aid_application, submission_builder) }

    let(:legal_aid_application) { create(:legal_aid_application) }
    let(:cfe_submission) { create(:cfe_submission, legal_aid_application:) }
    let(:cfe_result) { create(:cfe_v5_result, submission: cfe_submission, result: legacy_result) }
    let(:submission_builder) { instance_double(CFECivil::SubmissionBuilder) }
    let(:store_compare_result) { instance_double(CFE::StoreCompareResult, call: "something") }
    let(:legacy_result) { cfe_legacy_result }
    let(:cfe_legacy_result) { file_fixture("cfe_civil_comparison/v5/result.json").read }
    let(:cfe_civil_result) { file_fixture("cfe_civil_comparison/v6/result.json").read }

    before { allow(CFE::StoreCompareResult).to receive(:new).and_return(store_compare_result) }

    context "when the two results do not match" do
      before do
        allow(cfe_result).to receive(:result).and_return(cfe_legacy_result)
        allow(submission_builder).to receive(:cfe_result).and_return(cfe_civil_result)
        allow(submission_builder).to receive(:request_body).and_return({ "fake" => "return" })
      end

      it "calls CFE::StoreComparisonResult" do
        expect(store_compare_result).to receive(:call).once
        call
      end

      it { expect(call).to be false }
    end

    context "when the results match" do
      let(:legacy_result) { cfe_civil_result }

      before do
        allow(cfe_result).to receive(:result).and_return(cfe_civil_result)
        allow(submission_builder).to receive(:cfe_result).and_return(cfe_civil_result)
        allow(submission_builder).to receive(:request_body).and_return({ "fake" => "return" })
      end

      it "calls CFE::StoreComparisonResult" do
        expect(store_compare_result).to receive(:call).once
        call
      end

      it { expect(call).to be true }
    end

    context "when on UAT" do
      before do
        allow(HostEnv).to receive(:environment).and_return(:uat)
        allow(cfe_result).to receive(:result).and_return(cfe_legacy_result)
        allow(submission_builder).to receive(:cfe_result).and_return(cfe_civil_result)
        allow(submission_builder).to receive(:request_body).and_return({ "fake" => "return" })
      end

      it "calls CFE::StoreComparisonResult" do
        expect(store_compare_result).to receive(:call).once
        call
      end
    end

    context "when data is missing" do
      let(:submission_builder) { nil }

      it "raises an error" do
        expect { call }.to raise_error(StandardError, "Cannot compare CFE results")
      end
    end

    context "when there is a result with a multi array area in different sequences" do
      let(:cfe_legacy_result) { file_fixture("cfe_civil_comparison/v5/sequence_mismatch.json").read }
      let(:cfe_civil_result) { file_fixture("cfe_civil_comparison/v6/sequence_mismatch.json").read }

      before do
        allow(cfe_result).to receive(:result).and_return(cfe_legacy_result)
        allow(submission_builder).to receive(:cfe_result).and_return(cfe_civil_result)
        allow(submission_builder).to receive(:request_body).and_return({ "fake" => "return" })
      end

      it { expect(call).to be true }
    end

    context "when there is a result with a multi array area with mismatched values" do
      let(:cfe_legacy_result) { file_fixture("cfe_civil_comparison/v5/mismatch_array.json").read }
      let(:cfe_civil_result) { file_fixture("cfe_civil_comparison/v6/mismatch_array.json").read }

      before do
        allow(cfe_result).to receive(:result).and_return(cfe_legacy_result)
        allow(submission_builder).to receive(:cfe_result).and_return(cfe_civil_result)
        allow(submission_builder).to receive(:request_body).and_return({ "fake" => "return" })
      end

      it { expect(call).to be false }
    end

    context "when there is a result with a flat array area with mismatching values" do
      let(:cfe_legacy_result) { file_fixture("cfe_civil_comparison/v5/flat_array.json").read }
      let(:cfe_civil_result) { file_fixture("cfe_civil_comparison/v6/flat_array.json").read }

      before do
        allow(cfe_result).to receive(:result).and_return(cfe_legacy_result)
        allow(submission_builder).to receive(:cfe_result).and_return(cfe_civil_result)
        allow(submission_builder).to receive(:request_body).and_return({ "fake" => "return" })
      end

      it { expect(call).to be false }
    end

    context "when there is are results with rounding issues" do
      let(:cfe_legacy_result) { file_fixture("cfe_civil_comparison/v5/rounding.json").read }
      let(:cfe_civil_result) { file_fixture("cfe_civil_comparison/v6/rounding.json").read }

      before do
        allow(cfe_result).to receive(:result).and_return(cfe_legacy_result)
        allow(submission_builder).to receive(:cfe_result).and_return(cfe_civil_result)
        allow(submission_builder).to receive(:request_body).and_return({ "fake" => "return" })
      end

      it { expect(call).to be true }
    end

    context "when the assessment/gross_income/employment_income/0/payments sequence does not match" do
      let(:cfe_legacy_result) { file_fixture("cfe_civil_comparison/v5/payment_sequence_mismatch_array.json").read }
      let(:cfe_civil_result) { file_fixture("cfe_civil_comparison/v6/payment_sequence_mismatch_array.json").read }

      before do
        allow(cfe_result).to receive(:result).and_return(cfe_legacy_result)
        allow(submission_builder).to receive(:cfe_result).and_return(cfe_civil_result)
        allow(submission_builder).to receive(:request_body).and_return({ "fake" => "return" })
      end

      it { expect(call).to be true }
    end

    context "when the assessment/capital/capital_items/vehicles value is empty in v6" do
      let(:cfe_legacy_result) { file_fixture("cfe_civil_comparison/v5/missing_vehicle.json").read }
      let(:cfe_civil_result) { file_fixture("cfe_civil_comparison/v6/missing_vehicle.json").read }

      before do
        allow(cfe_result).to receive(:result).and_return(cfe_legacy_result)
        allow(submission_builder).to receive(:cfe_result).and_return(cfe_civil_result)
        allow(submission_builder).to receive(:request_body).and_return({ "fake" => "return" })
      end

      it { expect(call).to be false }
    end

    context "when the /assessment/gross_income/employment_income value is empty in v6" do
      let(:cfe_legacy_result) { file_fixture("cfe_civil_comparison/v5/employment_mismatch.json").read }
      let(:cfe_civil_result) { file_fixture("cfe_civil_comparison/v6/employment_mismatch.json").read }

      before do
        allow(cfe_result).to receive(:result).and_return(cfe_legacy_result)
        allow(submission_builder).to receive(:cfe_result).and_return(cfe_civil_result)
        allow(submission_builder).to receive(:request_body).and_return({ "fake" => "return" })
      end

      it { expect(call).to be false }
    end
  end
end
