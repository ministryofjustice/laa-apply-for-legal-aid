require 'rails_helper'

RSpec.describe TrueLayer::Importers::ImportTransactionsService do
  let(:mock_account) { TrueLayerHelpers::MOCK_DATA[:accounts].first }
  let(:bank_account) { create :bank_account, true_layer_id: mock_account[:account_id] }
  let(:api_client) { TrueLayer::ApiClient.new(bank_account.bank_provider.token) }

  describe '#call' do
    let(:now) { '6/11/2018 15:10:00 +0000'.to_time }
    let(:now_minus_3_month) { '5/08/2018 00:00:00 +0000'.to_time }
    let(:mock_transaction_1) { mock_account[:transactions][0] }
    let(:mock_transaction_2) { mock_account[:transactions][1] }
    let(:transaction_1) { bank_account.bank_transactions.find_by(true_layer_id: mock_transaction_1[:transaction_id]) }
    let(:transaction_2) { bank_account.bank_transactions.find_by(true_layer_id: mock_transaction_2[:transaction_id]) }
    let!(:existing_transaction) { create :bank_transaction, bank_account: bank_account }

    subject { described_class.call(api_client, bank_account) }

    before do
      allow(Time).to receive(:now).and_return(now)
    end

    context 'request is successful' do
      before do
        stub_true_layer_transactions
      end

      it 'adds the bank transactions to the bank_account' do
        subject
        expect(transaction_1.true_layer_response).to eq(mock_transaction_1.deep_stringify_keys)
        expect(transaction_1.true_layer_id).to eq(mock_transaction_1[:transaction_id])
        expect(transaction_2.true_layer_response).to eq(mock_transaction_2.deep_stringify_keys)
        expect(transaction_2.true_layer_id).to eq(mock_transaction_2[:transaction_id])
      end

      it 'removes existing transactions' do
        subject
        expect { existing_transaction.reload }.to raise_error ActiveRecord::RecordNotFound
      end

      it 'requests 3 months of transactions' do
        subject

        expected_request_url = [
          TrueLayer::ApiClient::TRUE_LAYER_URL,
          "/data/v1/accounts/#{mock_account[:account_id]}/transactions"
        ].join('')

        expect(WebMock).to have_requested(:get, expected_request_url)
          .with(query: {
                  from: now_minus_3_month.utc.iso8601,
                  to: now.utc.iso8601
                })
      end
    end

    context 'request is not successful' do
      before do
        stub_true_layer_error
      end

      it 'does not change anything' do
        expect { subject }.not_to change { bank_account.bank_transactions.count }
      end

      it 'returns an error' do
        expect(subject.errors.keys.first).to eq(:import_transactions)
      end
    end
  end
end
