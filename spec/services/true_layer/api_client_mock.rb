require 'rails_helper'

RSpec.describe TrueLayer::ApiClientMock do
  subject { described_class.new(SecureRandom.hex) }

  describe '#provider' do
    it 'returns sample data' do
      expect(subject.provider.value).to eq(TrueLayer::SampleData::PROVIDERS)
    end
  end

  describe '#account_holders' do
    it 'returns sample data' do
      expect(subject.account_holders.value).to eq(TrueLayer::SampleData::ACCOUNT_HOLDERS)
    end
  end

  describe '#accounts' do
    it 'returns sample data' do
      expect(subject.accounts.value).to eq(TrueLayer::SampleData::ACCOUNTS)
    end
  end

  describe '#transactions' do
    it 'returns sample data' do
      expect(subject.transactions.value).to eq(TrueLayer::SampleData::TRANSACTIONS)
    end
  end

  describe '#account_balance' do
    it 'returns sample data' do
      expect(subject.account_balance.value).to eq(TrueLayer::SampleData::BALANCES)
    end
  end
end
