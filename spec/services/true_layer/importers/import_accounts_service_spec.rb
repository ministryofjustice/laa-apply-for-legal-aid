require 'rails_helper'

RSpec.describe TrueLayer::Importers::ImportAccountsService do
  let(:bank_provider) { create :bank_provider }
  let(:api_client) { TrueLayer::ApiClient.new(bank_provider.token) }

  subject { described_class.new(api_client, bank_provider) }

  describe '#call' do
    let(:mock_account_1) { TrueLayerHelpers::MOCK_DATA[:accounts][0] }
    let(:mock_account_2) { TrueLayerHelpers::MOCK_DATA[:accounts][1] }
    let(:bank_account_1) { bank_provider.bank_accounts.find_by(true_layer_id: mock_account_1[:account_id]) }
    let(:bank_account_2) { bank_provider.bank_accounts.find_by(true_layer_id: mock_account_2[:account_id]) }
    let!(:existing_bank_account) { create :bank_account_holder, bank_provider: bank_provider }
    let!(:existing_bank_account) { create :bank_account, bank_provider: bank_provider }
    let!(:existing_bank_account_transaction) { create :bank_transaction, bank_account: existing_bank_account }

    context 'request is successful' do
      before do
        stub_true_layer_accounts
      end

      it 'adds the bank accounts to the bank_provider' do
        subject.call
        expect(bank_account_1.true_layer_response).to eq(mock_account_1.deep_stringify_keys)
        expect(bank_account_1.true_layer_id).to eq(mock_account_1[:account_id])
        expect(bank_account_1.name).to eq(mock_account_1[:display_name])
        expect(bank_account_1.currency).to eq(mock_account_1[:currency])
        expect(bank_account_1.account_number).to eq(mock_account_1[:account_number][:number])
        expect(bank_account_1.sort_code).to eq(mock_account_1[:account_number][:sort_code])
        expect(bank_account_2.true_layer_response).to eq(mock_account_2.deep_stringify_keys)
        expect(bank_account_2.true_layer_id).to eq(mock_account_2[:account_id])
      end

      it 'removes existing bank account and transactions' do
        subject.call
        expect { existing_bank_account.reload }.to raise_error ActiveRecord::RecordNotFound
        expect { existing_bank_account_transaction.reload }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    context 'request is not successful' do
      before do
        stub_true_layer_error
      end

      it 'leaves the list of bank accounts empty' do
        expect { subject.call }.to change { bank_provider.bank_accounts.count }.to(0)
      end
    end
  end
end
