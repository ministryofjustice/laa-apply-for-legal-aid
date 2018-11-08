require 'rails_helper'

RSpec.describe TrueLayer::Importers::ImportAccountsService do
  let(:bank_provider) { create :bank_provider }
  let(:api_client) { TrueLayer::ApiClient.new(bank_provider.token) }

  subject { described_class.new(api_client, bank_provider) }

  describe '#call' do
    let(:path) { '/data/v1/accounts' }
    let(:endpoint) { TrueLayer::ApiClient::TRUE_LAYER_URL + path }
    let(:result_1) do
      {
        account_id: SecureRandom.hex,
        display_name: Faker::Bank.name,
        currency: Faker::Currency.code,
        account_number: {
          number: Faker::Number.number(10),
          sort_code: Faker::Number.number(6)
        }
      }
    end
    let(:result_2) do
      {
        account_id: SecureRandom.hex,
        display_name: Faker::Bank.name,
        currency: Faker::Currency.code,
        account_number: {
          number: Faker::Number.number(10),
          sort_code: Faker::Number.number(6)
        }
      }
    end
    let(:results) { [result_1, result_2] }
    let(:response_body) { { results: results }.to_json }
    let(:bank_account_1) { bank_provider.bank_accounts.find_by(true_layer_id: result_1[:account_id]) }
    let(:bank_account_2) { bank_provider.bank_accounts.find_by(true_layer_id: result_2[:account_id]) }
    let!(:existing_bank_account) { create :bank_account, bank_provider: bank_provider }
    let!(:existing_bank_account_transaction) { create :bank_transaction, bank_account: existing_bank_account }

    before do
      stub_request(:get, endpoint).to_return(body: response_body)
    end

    it 'adds the bank accounts to the bank_provider' do
      subject.call
      expect(bank_account_1.true_layer_response).to eq(result_1.deep_stringify_keys)
      expect(bank_account_1.true_layer_id).to eq(result_1[:account_id])
      expect(bank_account_1.name).to eq(result_1[:display_name])
      expect(bank_account_1.currency).to eq(result_1[:currency])
      expect(bank_account_1.account_number).to eq(result_1[:account_number][:number])
      expect(bank_account_1.sort_code).to eq(result_1[:account_number][:sort_code])
      expect(bank_account_2.true_layer_response).to eq(result_2.deep_stringify_keys)
      expect(bank_account_2.true_layer_id).to eq(result_2[:account_id])
    end

    it 'removes existing bank account and transactions' do
      subject.call
      expect { existing_bank_account.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { existing_bank_account_transaction.reload }.to raise_error ActiveRecord::RecordNotFound
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

      it 'leaves the list of bank accounts empty' do
        expect { subject.call }.to change { bank_provider.bank_accounts.count }.to(0)
      end
    end
  end
end
