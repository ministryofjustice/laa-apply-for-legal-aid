require 'rails_helper'

RSpec.describe TrueLayer::BankDataImportService do
  let(:token) { SecureRandom.hex }
  let(:token_expires_at) { Time.current + 1.hour }
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :with_transaction_period, :with_non_passported_state_machine }
  let(:applicant) { legal_aid_application.applicant }

  before do
    Setting.delete_all
    applicant.store_true_layer_token(token: token, expires: token_expires_at)
  end

  subject { described_class.call(legal_aid_application: legal_aid_application) }

  describe '#call' do
    let(:bank_provider) { applicant.bank_providers.find_by(token: applicant.true_layer_secure_data_id) }
    let(:mock_data) { TrueLayerHelpers::MOCK_DATA }
    let(:bank_error) { applicant.bank_errors.first }
    let(:api_error) do
      {
        error_description: 'Feature not supported by the provider',
        error: :endpoint_not_supported,
        error_details: { foo: :bar }
      }
    end

    before { stub_true_layer }

    it 'imports the bank provider' do
      expect { subject }.to change { applicant.bank_providers.count }.by(1)
      expect(bank_provider.credentials_id).to eq(mock_data[:provider][:credentials_id])
      expect(bank_provider.token_expires_at.utc.to_s).to eq(token_expires_at.utc.to_s)
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
      mock_transaction_ids = mock_data[:accounts].flat_map { |a| a[:transactions].pluck(:transaction_id) }.sort
      expect { subject }.to change { BankTransaction.count }.by(mock_transaction_ids.count)

      transaction_ids = bank_provider.bank_accounts.flat_map(&:bank_transactions).pluck(:true_layer_id).sort
      expect(transaction_ids).to eq(mock_transaction_ids)
    end

    it 'is successful' do
      expect(subject.success?).to eq(true)
    end

    context 'the provider API call is failing' do
      before do
        endpoint = "#{TrueLayer::ApiClient::TRUE_LAYER_URL}/data/v1/me"
        stub_request(:get, endpoint).to_return(body: api_error.to_json, status: 501)
      end

      it 'returns an error' do
        expect(subject.errors.keys.first).to eq(:bank_data_import)
      end
    end

    context 'a subsequent API call is failing' do
      before do
        endpoint = "#{TrueLayer::ApiClient::TRUE_LAYER_URL}/data/v1/accounts"
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

    context 'mock_true_layer_data is on' do
      let(:sample_data) { TrueLayer::SampleData }
      before { Setting.create!(mock_true_layer_data: true) }

      it 'uses the Mock ApiClient' do
        expect(TrueLayer::ApiClient).not_to receive(:new)
        expect(TrueLayer::ApiClientMock).to receive(:new).and_call_original
        subject
      end

      it 'imports the sample data' do
        expect { subject }.to change { applicant.bank_providers.count }.by(1)
        expect(bank_provider.credentials_id).to eq(sample_data::PROVIDERS.first[:credentials_id])
        expect(bank_provider.bank_accounts.pluck(:true_layer_id).sort).to eq(sample_data::ACCOUNTS.pluck(:account_id).sort)
      end
    end
  end
end
