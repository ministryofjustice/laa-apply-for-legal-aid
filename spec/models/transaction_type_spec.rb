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

    context 'when a transaction type has been removed from the model' do
      let!(:old_transaction_type) { create :transaction_type, name: :council_tax }
      it 'sets the archived_at date in the database' do
        subject
        expect(described_class.find_by(name: 'council_tax').archived_at).to_not eq nil
      end

      it 'does not set the archived_at date in the database for active transaction types' do
        subject
        names.values.flatten.each do |transaction_name|
          expect(described_class.find_by(name: transaction_name).archived_at).to eq nil
        end
      end
    end
  end

  describe '#populate_without_income' do
    # this is called from an old migration
    subject { described_class.populate_without_income }

    it 'does not attempt to update other_income fields' do
      subject
      expect(TransactionType.where(other_income: true).count).to eq 0
    end
  end

  describe '#for_income_type?' do
    context 'checks that a boolean response is returned' do
      let!(:credit_transaction) { create :transaction_type, :credit_with_standard_name }

      it ' returns true with a valid income_type' do
        expect(described_class.for_income_type?(credit_transaction['name'])).to eq true
      end
    end

    context 'checks for boolean response' do
      let!(:debit_transaction) { create :transaction_type, :debit_with_standard_name }

      it ' returns false when a non valid income type is used' do
        expect(described_class.for_income_type?(debit_transaction['name'])).to eq false
      end
    end
  end

  describe '#for_outgoing_type?' do
    before { create :transaction_type, :child_care }
    context 'no such outgoing types exist' do
      it 'returns false' do
        expect(TransactionType.for_outgoing_type?('maintenance_out')).to be false
      end
    end

    context 'outgoing types do exist' do
      before { create :transaction_type, :maintenance_out }
      it 'returns true' do
        expect(TransactionType.for_outgoing_type?('maintenance_out')).to be true
      end
    end
  end

  describe '.other_income' do
    it 'returns all other_income type TransactionTypes' do
      TransactionType.populate
      names = TransactionType.other_income.pluck(:name)
      expect(names).to eq %w[friends_or_family maintenance_in property_or_lodger student_loan pension]
    end
  end
end
