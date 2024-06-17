require "rails_helper"

RSpec.describe Flow::Steps::ProviderIncome::IncomingTransactionsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:transaction_type) { create(:transaction_type, :maintenance_in) }
  let(:params) { { transaction_type: transaction_type.name } }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application, params) }

    it { is_expected.to eql providers_legal_aid_application_incoming_transactions_path(legal_aid_application, transaction_type.name) }
  end

  describe "#forward" do
    subject(:forward_step) { described_class.forward }

    it { is_expected.to eq :income_summary }
  end
end
