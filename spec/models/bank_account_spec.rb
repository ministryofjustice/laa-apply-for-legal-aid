require 'rails_helper'

RSpec.describe BankAccount, type: :model do
  describe '#account_type_label' do
    let(:not_defined_account_type) { 'LIFE_ISA' }

    it 'maps the account_type from TrueLayer' do
      described_class::ACCOUNT_TYPE_LABELS.each do |key, val|
        bank_account = create :bank_account, account_type: key
        result = bank_account.account_type_label
        expect(result).to eq(val), "account_type #{key} should be mapped to #{val}, got #{result}"
      end
    end

    it 'defaults to TrueLayer account_type if not defined in the mapping hash' do
      bank_account = create :bank_account, account_type: not_defined_account_type
      expect(bank_account.account_type_label).to eq(not_defined_account_type)
    end

    context 'savings type' do
      it 'returns Bank Savings' do
        bank_account = create :bank_account, account_type: 'SAVINGS'
        expect(bank_account.account_type_label).to eq('Bank Savings')
      end
    end
    context 'transactions type' do
      it 'returns Bank Current' do
        bank_account = create :bank_account, account_type: 'TRANSACTION'
        expect(bank_account.account_type_label).to eq('Bank Current')
      end
    end
  end

  describe '#holder_type' do
    it 'returns the correct account holder' do
      bank_account = create :bank_account
      expect(bank_account.holder_type).to eq 'Client Sole'
    end
  end

  describe '#display_name' do
    it 'returns the correct display name' do
      bank_account = create :bank_account
      bank_account.bank_provider.name = 'Test Bank'
      bank_account.account_number = '123456789'
      expect(bank_account.display_name).to eq 'Test Bank Acct 123456789'
    end
  end

  describe '#benefits ' do
    it 'returns true if benefits present' do
      bank_account = create :bank_account
      create :bank_transaction, :benefits, bank_account: bank_account
      expect(bank_account.has_benefits?).to eq true
    end
    it 'returns false if benefits not present' do
      bank_account = create :bank_account
      create :bank_transaction, :with_meta_tax, bank_account: bank_account
      expect(bank_account.has_benefits?).to eq false
    end
  end

  describe '#tax_credits ' do
    it 'returns false if tax credits not present' do
      bank_account = create :bank_account
      create :bank_transaction, :benefits, bank_account: bank_account
      expect(bank_account.has_tax_credits?).to eq false
    end
    it 'returns true if tax credits are present' do
      bank_account = create :bank_account
      create :bank_transaction, :with_meta_tax, bank_account: bank_account
      expect(bank_account.has_tax_credits?).to eq true
    end
  end

  describe '#latest_balance' do
    let(:bank_account) { create :bank_account }

    context 'transactions exist' do
      before { create_transactions }
      it 'returns the running balance of the latest transaction' do
        expect(bank_account.latest_balance).to eq 415.26
      end
    end

    context 'no bank transactions' do
      it 'returns zero' do
        expect(bank_account.bank_transactions.size).to eq 0
        expect(bank_account.latest_balance).to eq 0.0
      end
    end

    def create_transactions
      create :bank_transaction, bank_account: bank_account, happened_at: 2.days.ago, running_balance: 300.44
      create :bank_transaction, bank_account: bank_account, happened_at: 2.days.ago, running_balance: 400.44
      create :bank_transaction, bank_account: bank_account, happened_at: Date.current, running_balance: 415.26
    end
  end
end
