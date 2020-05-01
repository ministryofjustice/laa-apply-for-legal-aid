require 'rails_helper'

RSpec.describe BankTransaction do
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
