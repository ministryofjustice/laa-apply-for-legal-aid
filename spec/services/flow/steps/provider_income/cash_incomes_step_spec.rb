require "rails_helper"

RSpec.describe Flow::Steps::ProviderIncome::CashIncomesStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_means_cash_income_path(legal_aid_application) }
  end

  describe "#forward" do
    subject(:forward_step) { described_class.forward }

    it { is_expected.to eq :student_finances }
  end

  describe "#check_answers" do
    subject { described_class.check_answers.call(legal_aid_application) }

    context "when application has attached bank statement(s)" do
      before { allow(legal_aid_application).to receive(:uploading_bank_statements?).and_return(true) }

      it { is_expected.to eq :check_income_answers }
    end

    context "when application does not have attached bank statement(s)" do
      before { allow(legal_aid_application).to receive(:uploading_bank_statements?).and_return(false) }

      it { is_expected.to eq :income_summary }
    end
  end
end
