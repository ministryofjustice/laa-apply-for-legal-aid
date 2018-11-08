require 'rails_helper'

RSpec.describe TrueLayer::Importers::ImportTransactionsService do
  let(:bank_account) { create :bank_account }
  let(:api_client) { TrueLayer::ApiClient.new(bank_account.bank_provider.token) }

  subject { described_class.new(api_client, bank_account) }

  describe '#call' do
    let(:path) { "/data/v1/accounts/#{bank_account.true_layer_id}/transactions" }
    let(:endpoint) { TrueLayer::ApiClient::TRUE_LAYER_URL + path }
    let(:result_1) do
      {
        transaction_id: SecureRandom.hex
      }
    end
    let(:result_2) do
      {
        transaction_id: SecureRandom.hex
      }
    end
    let(:results) { [result_1, result_2] }
    let(:response_body) { { results: results }.to_json }
    let(:transaction_1) { bank_account.bank_transactions.find_by(true_layer_id: result_1[:transaction_id]) }
    let(:transaction_2) { bank_account.bank_transactions.find_by(true_layer_id: result_2[:transaction_id]) }
    let!(:existing_transaction) { create :bank_transaction, bank_account: bank_account }

    before do
      stub_request(:get, endpoint).to_return(body: response_body)
    end

    it 'adds the bank transactions to the bank_account' do
      subject.call
      expect(transaction_1.true_layer_response).to eq(result_1.deep_stringify_keys)
      expect(transaction_1.true_layer_id).to eq(result_1[:transaction_id])
      expect(transaction_2.true_layer_response).to eq(result_2.deep_stringify_keys)
      expect(transaction_2.true_layer_id).to eq(result_2[:transaction_id])
    end

    it 'removes existing transactions' do
      subject.call
      expect { existing_transaction.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    context 'request is not successful' do
      let(:response_body) do
        {
          error_description: 'Feature not supported by the provider',
          error: :endpoint_not_supported,
          error_details: {}
        }.to_json
      end

      before do
        stub_request(:get, endpoint).to_return(body: response_body, status: 501)
      end

      it 'leaves the list of transactions empty' do
        expect { subject.call }.to change { bank_account.bank_transactions.count }.to(0)
      end
    end
  end
end
