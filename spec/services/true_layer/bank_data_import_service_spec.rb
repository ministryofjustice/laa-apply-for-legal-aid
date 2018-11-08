require 'rails_helper'

RSpec.describe TrueLayer::BankDataImportService do
  let(:token) { SecureRandom.hex }
  let(:applicant) { create :applicant }
  let(:bank_provider) { create :bank_provider, applicant: applicant }
  let!(:account_1) { create :bank_account, bank_provider: bank_provider }
  let!(:account_2) { create :bank_account, bank_provider: bank_provider }

  subject { described_class.new(applicant: applicant, token: token) }

  describe '#call' do
    let(:api_client) { double(TrueLayer::ApiClient) }
    let(:import_provider_service) { spy(TrueLayer::Importers::ImportProviderService) }
    let(:import_accounts_service) { spy(TrueLayer::Importers::ImportAccountsService) }
    let(:import_account_holders_service) { spy(TrueLayer::Importers::ImportAccountHoldersService) }
    let(:import_balance_service_1) { spy(TrueLayer::Importers::ImportAccountBalanceService) }
    let(:import_balance_service_2) { spy(TrueLayer::Importers::ImportAccountBalanceService) }
    let(:import_transactions_service_1) { spy(TrueLayer::Importers::ImportTransactionsService) }
    let(:import_transactions_service_2) { spy(TrueLayer::Importers::ImportTransactionsService) }

    before do
      allow(TrueLayer::ApiClient).to receive(:new).with(token).and_return(api_client)

      allow(TrueLayer::Importers::ImportProviderService).to receive(:new).with(api_client, applicant, token).and_return(import_provider_service)
      allow(import_provider_service).to receive(:call).and_return(bank_provider)

      allow(TrueLayer::Importers::ImportAccountsService).to receive(:new).with(api_client, bank_provider).and_return(import_accounts_service)
      allow(import_accounts_service).to receive(:call).and_return(nil)

      allow(TrueLayer::Importers::ImportAccountHoldersService).to receive(:new).with(api_client, bank_provider).and_return(import_account_holders_service)
      allow(import_account_holders_service).to receive(:call).and_return(nil)

      allow(TrueLayer::Importers::ImportAccountBalanceService).to receive(:new).with(api_client, account_1).and_return(import_balance_service_1)
      allow(import_balance_service_1).to receive(:call).and_return(nil)

      allow(TrueLayer::Importers::ImportAccountBalanceService).to receive(:new).with(api_client, account_2).and_return(import_balance_service_2)
      allow(import_balance_service_2).to receive(:call).and_return(nil)

      allow(TrueLayer::Importers::ImportTransactionsService).to receive(:new).with(api_client, account_1).and_return(import_transactions_service_1)
      allow(import_transactions_service_1).to receive(:call).and_return(nil)

      allow(TrueLayer::Importers::ImportTransactionsService).to receive(:new).with(api_client, account_2).and_return(import_transactions_service_2)
      allow(import_transactions_service_2).to receive(:call).and_return(nil)
    end

    it 'imports the bank provider' do
      expect(import_provider_service).to receive(:call)
      subject.call
    end

    it 'imports the bank accounts' do
      expect(import_accounts_service).to receive(:call)
      subject.call
    end

    it 'imports the bank account balances' do
      expect(import_balance_service_1).to receive(:call)
      expect(import_balance_service_2).to receive(:call)
      subject.call
    end

    it 'imports the bank account holders' do
      expect(import_account_holders_service).to receive(:call)
      subject.call
    end

    it 'imports the bank account balances' do
      expect(import_transactions_service_1).to receive(:call)
      expect(import_transactions_service_2).to receive(:call)
      subject.call
    end

    context 'bank_provider could not be retrieved' do
      let(:bank_provider) { nil }
      let!(:account_1) { nil }
      let!(:account_2) { nil }

      it 'skips the other resources' do
        expect(import_accounts_service).not_to receive(:call)
        expect(import_balance_service_1).not_to receive(:call)
        expect(import_account_holders_service).not_to receive(:call)
        expect(import_transactions_service_1).not_to receive(:call)
        subject.call
      end
    end
  end
end
