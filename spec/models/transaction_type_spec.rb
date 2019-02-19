require 'rails_helper'

RSpec.describe TransactionType, type: :model do
  describe '.populate' do
    subject { described_class.populate }
    let(:names) { described_class::NAMES }
    let(:credit_names) { names[:credit] }
    let(:debit_names) { names[:debit] }
    let(:total) { credit_names.length + debit_names.length }

    it 'creates instances from names' do
      expect { subject }.to change { described_class.count }.by(total)
    end

    it 'assigns the names to the correct operation' do
      subject
      expect(described_class.debits.count).to eq(debit_names.length)
      expect(described_class.credits.count).to eq(credit_names.length)
      expect(debit_names.map(&:to_s)).to include(described_class.debits.first.name)
      expect(credit_names.map(&:to_s)).to include(described_class.credits.first.name)
    end

    context 'when transactions exists' do
      let!(:credit_transaction_type) { create :transaction_type, :credit_with_standard_name }
      let!(:debit_transaction_type) { create :transaction_type, :debit_with_standard_name }
      it 'creates one less transaction type' do
        expect { subject }.to change { described_class.count }.by(total - 2)
      end
    end

    context 'when run twice' do
      it 'creates the same total number of instancees' do
        expect {
          subject
          subject
        }.to change { described_class.count }.by(total)
      end
    end
  end
end
