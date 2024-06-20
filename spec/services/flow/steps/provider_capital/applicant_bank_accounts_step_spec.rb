require "rails_helper"

RSpec.describe Flow::Steps::ProviderCapital::ApplicantBankAccountsStep, type: :request do
  let(:application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(application) }

    it { is_expected.to eql providers_legal_aid_application_applicant_bank_account_path(application) }
  end

  describe "#forward" do
    subject(:forward_step) { described_class.forward.call(application) }

    context "when applicant's partner has a contrary interest" do
      before { allow(application.applicant).to receive(:has_partner_with_no_contrary_interest?).and_return(true) }

      it { is_expected.to eq :partner_bank_accounts }
    end

    context "when applicant's partner does not have a contrary interest" do
      before { allow(application.applicant).to receive(:has_partner_with_no_contrary_interest?).and_return(false) }

      it { is_expected.to eq :savings_and_investments }
    end

    describe "#check_answers" do
      subject { described_class.check_answers }

      it { is_expected.to eq :check_capital_answers }
    end
  end
end
