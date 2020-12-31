require 'rails_helper'

RSpec.describe TrueLayer::Importers::ImportAccountsService do
  let(:bank_provider) { create :bank_provider }
  let(:api_client) { TrueLayer::ApiClient.new(bank_provider.token) }

  describe '#call' do
    let(:mock_account1) { TrueLayerHelpers::MOCK_DATA[:accounts][0] }
    let(:mock_account2) { TrueLayerHelpers::MOCK_DATA[:accounts][1] }
    let(:bank_account1) { bank_provider.bank_accounts.find_by(true_layer_id: mock_account1[:account_id]) }
    let(:bank_account2) { bank_provider.bank_accounts.find_by(true_layer_id: mock_account2[:account_id]) }
    let!(:existing_bank_account) { create :bank_account_holder, bank_provider: bank_provider }
    let!(:existing_bank_account) { create :bank_account, bank_provider: bank_provider }
    let!(:existing_bank_account_transaction) { create :bank_transaction, bank_account: existing_bank_account }

    subject { described_class.call(api_client, bank_provider) }

    context 'request is successful' do
      before do
        stub_true_layer_accounts
      end

      it 'adds the bank accounts to the bank_provider' do
        subject
        expect(bank_account1.true_layer_response).to eq(mock_account1.deep_stringify_keys)
        expect(bank_account1.true_layer_id).to eq(mock_account1[:account_id])
        expect(bank_account1.name).to eq(mock_account1[:display_name])
        expect(bank_account1.account_type).to eq(mock_account1[:account_type])
        expect(bank_account1.currency).to eq(mock_account1[:currency])
        expect(bank_account1.account_number).to eq(mock_account1[:account_number][:number])
        expect(bank_account1.sort_code).to eq(mock_account1[:account_number][:sort_code])
        expect(bank_account2.true_layer_response).to eq(mock_account2.deep_stringify_keys)
        expect(bank_account2.true_layer_id).to eq(mock_account2[:account_id])
      end

      it 'removes existing bank account and transactions' do
        subject
        expect { existing_bank_account.reload }.to raise_error ActiveRecord::RecordNotFound
        expect { existing_bank_account_transaction.reload }.to raise_error ActiveRecord::RecordNotFound
      end

      it 'is successful' do
        expect(subject.success?).to eq(true)
      end
    end

    context 'request is not successful' do
      before do
        stub_true_layer_error
      end

      it 'does not change anything' do
        expect { subject }.not_to change { bank_provider.bank_accounts.count }
      end

      it 'returns an error' do
        expect(subject.errors.keys.first).to eq(:import_accounts)
      end
    end
  end
end
