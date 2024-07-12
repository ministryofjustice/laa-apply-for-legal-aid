require "rails_helper"

RSpec.describe Flow::Steps::ProviderIncome::OutgoingTransactionsStep, type: :request do
  let(:application) { create(:legal_aid_application) }
  let(:transaction_type) { create(:transaction_type, :maintenance_in) }
  let(:params) { { transaction_type: transaction_type.name } }

  describe "#path" do
    subject { described_class.path.call(application, params) }

    it { is_expected.to eql providers_legal_aid_application_outgoing_transactions_path(application, transaction_type.name) }
  end

  describe "#forward" do
    subject(:forward_step) { described_class.forward }

    it { is_expected.to eq :outgoings_summary }
  end
end
