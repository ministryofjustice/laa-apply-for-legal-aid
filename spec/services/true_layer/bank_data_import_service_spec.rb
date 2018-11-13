require 'rails_helper'

RSpec.describe TrueLayer::BankDataImportService do
  let(:token) { SecureRandom.hex }
  let(:applicant) { create :applicant }
  let(:bank_provider) { applicant.bank_providers.find_by(token: token) }
  let(:mock_data) { TrueLayerHelpers::MOCK_DATA }

  subject { described_class.call(applicant: applicant, token: token) }

  describe '#call' do
    before { stub_true_layer }

    it 'imports the bank provider' do
      expect { subject }.to change { applicant.bank_providers.count }.by(1)
      expect(bank_provider.credentials_id).to eq(mock_data[:provider][:credentials_id])
    end

    it 'imports the bank accounts' do
      expect { subject }.to change { BankAccount.count }.by(mock_data[:accounts].count)
      mock_account_ids = mock_data[:accounts].pluck(:account_id).sort
      expect(bank_provider.bank_accounts.pluck(:true_layer_id).sort).to eq(mock_account_ids)
    end

    it 'imports the account balances' do
      subject
      mock_account_balances = mock_data[:accounts].map { |a| a[:balance][:current].to_s }.sort
      account_balances = bank_provider.bank_accounts.map { |a| a.balance.to_s }.sort
      expect(account_balances).to eq(mock_account_balances)
    end

    it 'imports the bank account holders' do
      expect { subject }.to change { BankAccountHolder.count }.by(mock_data[:account_holders].count)
    end

    it 'imports the transactions' do
      mock_transaction_ids = mock_data[:accounts].flat_map { |a| a[:transactions].map { |t| t[:transaction_id] } }.sort
      expect { subject }.to change { BankTransaction.count }.by(mock_transaction_ids.count)

      transaction_ids = bank_provider.bank_accounts.flat_map(&:bank_transactions).pluck(:true_layer_id).sort
      expect(transaction_ids).to eq(mock_transaction_ids)
    end

    it 'is successful' do
      expect(subject.success?).to eq(true)
    end

    context 'one API call is not successsful' do
      let(:bank_error) { applicant.bank_errors.first }
      let(:api_error) do
        {
          error_description: 'Feature not supported by the provider',
          error: :endpoint_not_supported,
          error_details: { foo: :bar }
        }
      end

      before do
        endpoint = TrueLayer::ApiClient::TRUE_LAYER_URL + '/data/v1/accounts'
        stub_request(:get, endpoint).to_return(body: api_error.to_json, status: 501)
      end

      it 'does not import anything' do
        expect { subject }
          .to change { BankProvider.count }
          .by(0)
          .and change { BankAccount.count }
          .by(0)
          .and change { BankAccountHolder.count }
          .by(0)
          .and change { BankTransaction.count }
          .by(0)
      end

      it 'returns an error' do
        expect(subject.errors.keys.first).to eq(:bank_data_import)
      end

      it 'saves the error in DB' do
        subject
        expect(bank_error.applicant).to eq(applicant)
        expect(bank_error.bank_name).to eq(mock_data[:provider][:provider][:display_name])
        expect(bank_error.error).to include(api_error.to_json)
      end
    end
  end
end
