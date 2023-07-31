require "rails_helper"

RSpec.describe TrueLayer::Importers::ImportTransactionsService do
  let(:mock_account) { TrueLayerHelpers::MOCK_DATA[:accounts].first }
  let(:bank_account) { create(:bank_account, true_layer_id: mock_account[:account_id]) }
  let(:api_client) { TrueLayer::ApiClient.new(SecureRandom.hex) }

  describe "#call" do
    subject(:call) { described_class.call(api_client, bank_account, start_at: now_minus_3_month, finish_at: now) }

    let(:now) { Time.utc(2018, 11, 6, 0, 0) }
    let(:now_minus_3_month) { Time.utc(2018, 8, 5, 0, 0) }
    let(:mock_transaction1) { mock_account[:transactions][0] }
    let(:mock_transaction2) { mock_account[:transactions][1] }
    let(:transaction1) { bank_account.bank_transactions.find_by(true_layer_id: mock_transaction1[:transaction_id]) }
    let(:transaction2) { bank_account.bank_transactions.find_by(true_layer_id: mock_transaction2[:transaction_id]) }
    let!(:existing_transaction) { create(:bank_transaction, bank_account:) }

    context "when the request is successful" do
      before do
        stub_true_layer_transactions
      end

      it "adds the bank transactions to the bank_account" do
        call
        expect(transaction1.true_layer_response).to eq(mock_transaction1.deep_stringify_keys)
        expect(transaction1.true_layer_id).to eq(mock_transaction1[:transaction_id])
        expect(transaction1.description).to eq(mock_transaction1[:description])
        expect(transaction1.merchant).to eq(mock_transaction1[:merchant_name])
        expect(transaction1.currency).to eq(mock_transaction1[:currency])
        expect(transaction1.amount.to_s).to eq(mock_transaction1[:amount].to_s)
        expect(transaction1.happened_at).to eq(Time.zone.parse(mock_transaction1[:timestamp]))
        expect(transaction1.operation).to eq(mock_transaction1[:transaction_type].downcase)
        expect(transaction1.running_balance.to_s).to eq(mock_transaction1.dig(:running_balance, :amount).to_s)

        expect(transaction2.true_layer_response).to eq(mock_transaction2.deep_stringify_keys)
        expect(transaction2.true_layer_id).to eq(mock_transaction2[:transaction_id])
        expect(transaction2.description).to eq(mock_transaction2[:description])
        expect(transaction2.merchant).to eq(mock_transaction2[:merchant_name])
        expect(transaction2.currency).to eq(mock_transaction2[:currency])
        expect(transaction2.amount.to_s).to eq(mock_transaction2[:amount].to_s)
        expect(transaction2.happened_at).to eq(Time.zone.parse(mock_transaction2[:timestamp]))
        expect(transaction2.operation).to eq(mock_transaction2[:transaction_type].downcase)
        expect(transaction2.running_balance.to_s).to eq(mock_transaction2.dig(:running_balance, :amount).to_s)
      end

      it "removes existing transactions" do
        call
        expect { existing_transaction.reload }.to raise_error ActiveRecord::RecordNotFound
      end

      it "requests 3 months of transactions" do
        call

        expected_request_url = [
          TrueLayer::ApiClient::TRUE_LAYER_URL,
          "/data/v1/accounts/#{mock_account[:account_id]}/transactions",
        ].join

        expect(WebMock).to have_requested(:get, expected_request_url)
          .with(query: {
            from: "2018-08-05T00:00:00Z",
            to: "2018-11-06T00:00:00Z",
          })
      end
    end

    context "when the request is not successful" do
      before do
        stub_true_layer_error
      end

      it "does not change anything" do
        expect { call }.not_to change { bank_account.bank_transactions.count }
      end

      it "returns an error" do
        expect(JSON.parse(call.errors.to_json).deep_symbolize_keys.keys.first).to eq(:import_transactions)
      end
    end
  end
end
