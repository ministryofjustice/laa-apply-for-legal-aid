require "rails_helper"

RSpec.describe Flow::Steps::ProviderIncome::ClientCompletedMeansStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_client_completed_means_path(legal_aid_application) }
  end

  describe "#forward" do
    subject(:forward_step) { described_class.forward.call(legal_aid_application) }

    before { allow(HMRC::StatusAnalyzer).to receive(:call).with(legal_aid_application).and_return(status) }

    context "when status is applicant_multiple_employments" do
      let(:status) { :applicant_multiple_employments }

      it { is_expected.to eq :full_employment_details }
    end

    context "when HMRC returns an applicant_no_hmrc_data status" do
      let(:status) { :applicant_no_hmrc_data }

      it { is_expected.to eq :full_employment_details }
    end

    context "when HMRC returns an applicant_single_employment status" do
      let(:status) { :applicant_single_employment }

      it { is_expected.to eq :employment_incomes }
    end

    context "when HMRC returns an applicant_unexpected_employment_data status" do
      let(:status) { :applicant_unexpected_employment_data }

      it { is_expected.to eq :unexpected_employment_incomes }
    end

    context "when HMRC returns an applicant_not_employed status" do
      let(:status) { :applicant_not_employed }

      context "when application has attached bank statement(s)" do
        before { allow(legal_aid_application).to receive(:uploading_bank_statements?).and_return(true) }

        it { is_expected.to eq :receives_state_benefits }
      end

      context "when application does not have attached bank statement(s)" do
        before { allow(legal_aid_application).to receive(:uploading_bank_statements?).and_return(false) }

        it { is_expected.to eq :identify_types_of_incomes }
      end

      context "when HMRC returns an unexpected status" do
        let(:status) { :unexpected_status }

        it "raises error" do
          expect { forward_step }.to raise_error(StandardError, "Unexpected hmrc status :unexpected_status")
        end
      end
    end
  end
end
