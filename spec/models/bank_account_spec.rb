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
end
