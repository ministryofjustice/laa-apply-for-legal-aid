require "rails_helper"

RSpec.describe Flow::Steps::ProviderCapital::PartnerBankAccountsStep, type: :request do
  let(:application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(application) }

    it { is_expected.to eql providers_legal_aid_application_partners_bank_accounts_path(application) }
  end

  describe "#forward" do
    subject(:forward_step) { described_class.forward }

    it { is_expected.to eq :savings_and_investments }
  end

  describe "#check_answers" do
    subject { described_class.check_answers }

    it { is_expected.to eq :check_capital_answers }
  end
end
