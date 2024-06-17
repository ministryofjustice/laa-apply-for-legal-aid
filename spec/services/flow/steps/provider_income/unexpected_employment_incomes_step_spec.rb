require "rails_helper"

RSpec.describe Flow::Steps::ProviderIncome::UnexpectedEmploymentIncomesStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_means_unexpected_employment_income_path(legal_aid_application) }
  end

  describe "#forward" do
    subject(:forward_step) { described_class.forward.call(legal_aid_application) }

    context "when application has attached bank statement(s)" do
      before { allow(legal_aid_application).to receive(:uploading_bank_statements?).and_return(true) }

      it { is_expected.to eq :regular_incomes }
    end

    context "when application does not have attached bank statement(s)" do
      before { allow(legal_aid_application).to receive(:uploading_bank_statements?).and_return(false) }

      it { is_expected.to eq :identify_types_of_incomes }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers }

    it { is_expected.to eq :check_income_answers }
  end
end
