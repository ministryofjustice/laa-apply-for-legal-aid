require 'rails_helper'

module CFE
  RSpec.describe RemarkedTransaction do
    let(:tx_id) { SecureRandom.uuid }
    let(:category) { :state_benefits }
    let(:transaction) { described_class.new(tx_id, category, :unknown_frequency) }

    describe '.new' do
      it 'instantiates a transaction with one reason' do
        expect(transaction.tx_id).to eq tx_id
        expect(transaction.category).to eq category
        expect(transaction.reasons).to eq [:unknown_frequency]
      end
    end

    describe '#update' do
      context 'non-matching tx_id' do
        it 'raises' do
          expect {
            transaction.update(SecureRandom.uuid, category, :unknown_frequency)
          }.to raise_error ArgumentError, 'Transaction Id mismatch'
        end
      end

      context 'non-matching category' do
        it 'raises' do
          expect {
            transaction.update(tx_id, :other_income, :unknown_frequency)
          }.to raise_error ArgumentError, 'Category mismatch'
        end
      end

      context 'adding a new reason' do
        it 'returns both the reasons in alphebetic order' do
          transaction.update(tx_id, category, :amount_variation)
          expect(transaction.reasons).to eq(%i[amount_variation unknown_frequency])
        end
      end

      context 'adding duplicate reason' do
        it 'returns both the reasons in alphebetic order' do
          transaction.update(tx_id, category, :amount_variation)
          transaction.update(tx_id, category, :unknown_frequency)
          expect(transaction.reasons).to eq(%i[amount_variation unknown_frequency])
        end
      end
    end
  end
end
