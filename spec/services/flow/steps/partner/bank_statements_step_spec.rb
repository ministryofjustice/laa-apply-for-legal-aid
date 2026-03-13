require "rails_helper"

RSpec.describe Flow::Steps::Partner::BankStatementsStep, type: :request do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_partners_bank_statements_path(legal_aid_application) }
  end

  describe "#forward" do
    subject(:forward_step) { described_class.forward.call(legal_aid_application) }

    before { allow(HMRC::StatusAnalyzer).to receive(:call).with(legal_aid_application).and_return(status) }

    context "when status is partner_not_employed_no_nino" do
      let(:status) { :partner_not_employed_no_nino }

      it { is_expected.to eq :partner_receives_state_benefits }
    end

    context "when status is partner_not_employed_hmrc_unavailable" do
      let(:status) { :partner_not_employed_hmrc_unavailable }

      it { is_expected.to eq :partner_receives_state_benefits }
    end

    context "when status is partner_not_employed_no_payments" do
      let(:status) { :partner_not_employed_no_payments }

      it { is_expected.to eq :partner_receives_state_benefits }
    end

    context "when status is partner_unexpected_no_employment_data" do
      let(:status) { :partner_unexpected_no_employment_data }

      it { is_expected.to eq :partner_employed_but_no_hmrc_data_interrupts }
    end

    context "when status is partner_employed_hmrc_unavailable" do
      let(:status) { :partner_employed_hmrc_unavailable }

      it { is_expected.to eq :partner_hmrc_unavailable_interrupts }
    end

    context "when status is partner_employed_no_nino" do
      let(:status) { :partner_employed_no_nino }

      it { is_expected.to eq :partner_no_nino_interrupts }
    end

    context "when status is partner_unexpected_employment_data" do
      let(:status) { :partner_unexpected_employment_data }

      it { is_expected.to eq :partner_unemployed_but_hmrc_found_data_interrupts }
    end

    context "when status is partner_multiple_employments" do
      let(:status) { :partner_multiple_employments }

      it { is_expected.to eq :partner_multiple_employments_interrupts }
    end

    context "when status is partner_single_employment" do
      let(:status) { :partner_single_employment }

      it { is_expected.to eq :partner_single_employment_interrupts }
    end

    context "when status is unexpected" do
      let(:status) { :unexpected }

      it { expect { forward_step }.to raise_error(RuntimeError, "Unexpected hmrc status :unexpected") }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers }

    it { is_expected.to eq :check_income_answers }
  end
end
