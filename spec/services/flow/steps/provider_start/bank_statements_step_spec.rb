require "rails_helper"

RSpec.describe Flow::Steps::ProviderStart::BankStatementsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_bank_statements_path(legal_aid_application) }
  end

  describe "#forward" do
    subject(:forward_step) { described_class.forward.call(legal_aid_application) }

    context "when HMRC status analyzer returns applicant_multiple_employments" do
      before do
        allow(HMRC::StatusAnalyzer).to receive(:call).and_return :applicant_multiple_employments
      end

      it { is_expected.to eq :full_employment_details }
    end

    context "when HMRC status analyzer returns applicant_no_hmrc_data" do
      before do
        allow(HMRC::StatusAnalyzer).to receive(:call).and_return :applicant_no_hmrc_data
      end

      it { is_expected.to eq :full_employment_details }
    end

    context "when HMRC status analyzer returns applicant_single_employment" do
      before do
        allow(HMRC::StatusAnalyzer).to receive(:call).and_return :applicant_single_employment
      end

      it { is_expected.to eq :employment_incomes }
    end

    context "when HMRC status analyzer returns applicant_unexpected_employment_data" do
      before do
        allow(HMRC::StatusAnalyzer).to receive(:call).and_return :applicant_unexpected_employment_data
      end

      it { is_expected.to eq :unexpected_employment_incomes }
    end

    context "when HMRC status analyzer returns applicant_not_employed" do
      before do
        allow(HMRC::StatusAnalyzer).to receive(:call).and_return :applicant_not_employed
      end

      it { is_expected.to eq :receives_state_benefits }
    end

    context "when HMRC response status is unexpected" do
      before do
        allow(HMRC::StatusAnalyzer).to receive(:call).and_return :foobar
      end

      it "raises error" do
        expect { forward_step }.to raise_error RuntimeError, "Unexpected hmrc status :foobar"
      end
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers }

    it { is_expected.to eq :check_income_answers }
  end
end
