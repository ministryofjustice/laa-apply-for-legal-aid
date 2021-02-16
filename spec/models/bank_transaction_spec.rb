require 'rails_helper'

RSpec.describe BankTransaction do
  describe '#parent_transaction_type' do
    before { Populators::TransactionTypePopulator.call }

    let(:benefits) { TransactionType.find_by(name: 'benefits') }
    let(:excluded_benefits) { TransactionType.find_by(name: 'excluded_benefits') }
    let(:pension) { TransactionType.find_by(name: 'pension') }

    context 'transaction type is not a child' do
      it 'returns the transaction type' do
        trx = create :bank_transaction, :credit, transaction_type: pension
        expect(trx.parent_transaction_type).to eq pension
      end
    end

    context 'transaction type is a child' do
      it 'returns the transaction type parent' do
        trx = create :bank_transaction, :credit, transaction_type: excluded_benefits
        expect(trx.parent_transaction_type).to eq benefits
      end
    end

    describe 'scope by parent_transaction_type' do
      it 'groups the transactions keyed by parent transaction type' do
        trx_p1 = create :bank_transaction, :credit, transaction_type: pension
        trx_p2 = create :bank_transaction, :credit, transaction_type: pension
        trx_b1 = create :bank_transaction, :credit, transaction_type: benefits
        trx_b2 = create :bank_transaction, :credit, transaction_type: benefits
        trx_eb1 = create :bank_transaction, :credit, transaction_type: excluded_benefits
        trx_eb2 = create :bank_transaction, :credit, transaction_type: excluded_benefits

        grouped_transactions = BankTransaction.by_parent_transaction_type
        expect(grouped_transactions[pension]).to match_array [trx_p1, trx_p2]
        expect(grouped_transactions[benefits]).to match_array [trx_b1, trx_b2, trx_eb1, trx_eb2]
      end
    end
  end

  context 'serialization of meta data' do
    context 'meta data is null' do
      let(:tx) { create :bank_transaction }
      it 'returns nil' do
        expect(tx.meta_data).to be_nil
      end

      it 'can be populated, saved and read back' do
        tx.meta_data = { name: 'my name', code: 'my_code', other_data: 'Other data' }
        tx.save!
        new_tx = BankTransaction.find(tx.id)
        expect(new_tx.meta_data).to eq({ name: 'my name', code: 'my_code', other_data: 'Other data' })
      end
    end

    context 'meta data is populated' do
      it 'returns a hash' do
        bt = create :bank_transaction, :with_meta
        expect(bt.meta_data[:code]).to eq 'UC'
        expect(bt.meta_data[:name]).to eq 'Universal credit'
        expect(bt.meta_data[:label]).to eq 'universal_credit'
      end
    end
  end
end
