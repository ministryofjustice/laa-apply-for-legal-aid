require 'rails_helper'

module CFE
  RSpec.describe RemarkedTransactionCollection do
    describe '#transactions' do
      let(:collection) { described_class.new }

      context 'empty collection' do
        it 'returns an empty hash' do
          expect(collection.transactions).to eq({})
        end
      end

      context 'with_transactions' do
        let(:tx_id1) { SecureRandom.uuid }
        let(:tx_id2) { SecureRandom.uuid }
        let(:category1) { :state_benefits }
        let(:category2) { :other_income }

        before do
          collection.update(tx_id1, category1, :unknown_frequency)
          collection.update(tx_id2, category2, :unknown_frequency)
          collection.update(tx_id1, category1, :amount_variation)
        end

        it 'returns collection of two transactions' do
          expect(collection.transactions.size).to eq 2
        end

        it 'contains a hash of RemarkedTansaction objects' do
          expect(collection.transactions.values.map(&:class).uniq).to eq [RemarkedTransaction]
        end

        it 'each remarked transaction contains the expected value' do
          tx = collection.transactions[tx_id1]
          expect(tx.tx_id).to eq tx_id1
          expect(tx.category).to eq :state_benefits
          expect(tx.reasons).to eq %i[amount_variation unknown_frequency]

          tx = collection.transactions[tx_id2]
          expect(tx.tx_id).to eq tx_id2
          expect(tx.category).to eq :other_income
          expect(tx.reasons).to eq [:unknown_frequency]
        end
      end
    end
  end
end
