require 'rails_helper'

RSpec.describe TrueLayer::Importers::ImportAccountBalanceService do
  let(:mock_account) { TrueLayerHelpers::MOCK_DATA[:accounts].first }
  let(:mock_result) { mock_account[:balance] }
  let(:bank_account) { create :bank_account, true_layer_id: mock_account[:account_id] }
  let(:api_client) { TrueLayer::ApiClient.new(bank_account.bank_provider.token) }

  subject { described_class.new(api_client, bank_account) }

  describe '#call' do
    context 'request is successful' do
      before do
        stub_true_layer_account_balances
      end

      it 'updates the balance of the account' do
        expect { subject.call }.to change { bank_account.balance.to_s }.to(mock_result[:current].to_s)
      end
    end

    context 'request is not successful' do
      before do
        stub_true_layer_error
      end

      it 'does not change the balance of the account' do
        expect { subject.call }.not_to change { bank_account.balance }
      end
    end
  end
end
