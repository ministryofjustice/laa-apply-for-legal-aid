require "rails_helper"

RSpec.describe Flow::Steps::ProviderCapital::OfflineAccountsStep, type: :request do
  let(:application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(application) }

    it { is_expected.to eql providers_legal_aid_application_offline_account_path(application) }
  end

  describe "#forward" do
    subject(:forward_step) { described_class.forward }

    it { is_expected.to eq :savings_and_investments }
  end

  describe "#check_answers" do
    subject { described_class.check_answers.call(application) }

    context "when applicant does not get a passporting benefit" do
      before { allow(application).to receive(:checking_non_passported_means?).and_return(true) }

      it { is_expected.to eq :check_capital_answers }
    end

    context "when applicant does get a passporting benefit" do
      before { allow(application).to receive(:checking_non_passported_means?).and_return(false) }

      it { is_expected.to eq :check_passported_answers }
    end
  end
end
