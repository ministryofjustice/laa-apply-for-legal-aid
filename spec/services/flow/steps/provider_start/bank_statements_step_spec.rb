require "rails_helper"

RSpec.describe Flow::Steps::ProviderStart::BankStatementsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_bank_statements_path(legal_aid_application) }
  end

  describe "#forward" do
    subject(:forward_step) { described_class.forward.call(legal_aid_application) }

    before { allow(HMRC::StatusAnalyzer).to receive(:call).with(legal_aid_application).and_return(status) }

    context "when status is applicant_not_employed_no_nino" do
      let(:status) { :applicant_not_employed_no_nino }

      it { is_expected.to eq :receives_state_benefits }
    end

    context "when status is applicant_not_employed_hmrc_unavailable" do
      let(:status) { :applicant_not_employed_hmrc_unavailable }

      it { is_expected.to eq :receives_state_benefits }
    end

    context "when status is applicant_not_employed_no_payments" do
      let(:status) { :applicant_not_employed_no_payments }

      it { is_expected.to eq :receives_state_benefits }
    end

    context "when status is applicant_unexpected_no_employment_data" do
      let(:status) { :applicant_unexpected_no_employment_data }

      it { is_expected.to eq :employed_but_no_hmrc_data_interrupts }
    end

    context "when status is applicant_employed_hmrc_unavailable" do
      let(:status) { :applicant_employed_hmrc_unavailable }

      it { is_expected.to eq :hmrc_unavailable_interrupts }
    end

    context "when status is applicant_employed_no_nino" do
      let(:status) { :applicant_employed_no_nino }

      it { is_expected.to eq :no_nino_interrupts }
    end

    context "when status is applicant_unexpected_employment_data" do
      let(:status) { :applicant_unexpected_employment_data }

      it { is_expected.to eq :unemployed_but_hmrc_found_data_interrupts }
    end

    context "when status is applicant_multiple_employments" do
      let(:status) { :applicant_multiple_employments }

      it { is_expected.to eq :multiple_employments_interrupts }
    end

    context "when status is applicant_single_employment" do
      let(:status) { :applicant_single_employment }

      it { is_expected.to eq :single_employment_interrupts }
    end

    context "when status is unexpected" do
      let(:status) { :foobar }

      it "raises an unexpected HMRC status error" do
        expect { forward_step }.to raise_error(RuntimeError, "Unexpected hmrc status :foobar")
      end
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers }

    it { is_expected.to eq :check_income_answers }
  end
end
