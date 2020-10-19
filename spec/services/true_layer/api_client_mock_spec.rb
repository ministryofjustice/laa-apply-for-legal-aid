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
    let(:result) { subject.transactions.value }

    it 'returns sample data' do
      expect(result).not_to be_empty
      expect(result.pluck(:transaction_id).compact).not_to be_empty
      expect(result.pluck(:description).compact).not_to be_empty
      expect(result.pluck(:currency).compact).not_to be_empty
      expect(result.pluck(:amount).compact).not_to be_empty
      expect(result.pluck(:timestamp).compact).not_to be_empty
      expect(result.pluck(:transaction_type).compact).not_to be_empty
    end

    it 'always returns the same data' do
      second_result = subject.transactions.value
      expect(result).to eq(second_result)
    end

    it 'returns unique transaction_ids' do
      transaction_ids = result.pluck(:transaction_id)
      expect(transaction_ids.uniq).to eq(transaction_ids)
    end

    context 'with known data' do
      let(:csv_file) { 'spec/fixtures/db/sample_data/bank_transactions.csv' }
      let(:expected_result) do
        [
          {
            transaction_id: 'rlucUGBnV28R3iGmffO0Z_zwpp0FOf5rKeRp4UJc',
            description: 'something with some spaces',
            currency: 'GBP',
            amount: -1234.56,
            timestamp: '2020-12-01 00:00:00 +0000',
            transaction_type: 'debit',
            running_balance: nil
          },
          {
            transaction_id: 'Gc9-6HF2-m9iBBYdKJ6p2_hUvaxlM6o8ktZtp6v4',
            description: 'simple',
            currency: 'GBP',
            amount: 1234.56,
            timestamp: '2010-01-12 00:00:00 +0000',
            transaction_type: 'credit',
            running_balance: nil
          },
          {
            transaction_id: 'iWEomIVMycq4bvAqBI5SgaGmrMWRnq-pQIHnLv_U',
            description: 'simple',
            currency: 'GBP',
            amount: 1234.56,
            timestamp: '2010-01-12 00:00:00 +0000',
            transaction_type: 'credit',
            running_balance: nil
          }
        ]
      end

      before do
        expect(Setting).to receive(:bank_transaction_filename).and_return(csv_file)
      end

      it 'returns the sample data' do
        expect(result).to eq(expected_result)
      end
    end
  end

  describe '#account_balance' do
    it 'returns sample data' do
      expect(subject.account_balance.value).to eq(TrueLayer::SampleData::BALANCES)
    end
  end
end
