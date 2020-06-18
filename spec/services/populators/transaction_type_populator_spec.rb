require 'rails_helper'

module Populators
  RSpec.describe TransactionTypePopulator do
    describe '.call' do
      subject { described_class.call }
      let(:names) { TransactionType::NAMES }
      let(:credit_names) { names[:credit] }
      let(:debit_names) { names[:debit] }
      let(:total) { credit_names.length + debit_names.length }
      let(:archived_credit_names) { %i[student_loan] }

      it 'creates instances from names' do
        expect { subject }.to change { TransactionType.count }.by(total)
      end

      it 'assigns the names to the correct operation' do
        subject
        expect(TransactionType.debits.count).to eq(debit_names.length)
        expect(TransactionType.credits.count).to eq(credit_names.length - archived_credit_names.length)
        expect(debit_names.map(&:to_s)).to include(TransactionType.debits.first.name)
        expect(credit_names.map(&:to_s)).to include(TransactionType.credits.first.name)
      end

      context 'when transaction types exist' do
        let!(:credit_transaction_type) { create :transaction_type, name: 'pension', operation: 'credit' }
        let!(:debit_transaction_type) { create :transaction_type, :debit_with_standard_name }

        it 'creates one less transaction type' do
          expect { subject }.to change { TransactionType.count }.by(total - 2)
        end
      end

      context 'when run twice' do
        it 'creates the same total number of instancees' do
          expect {
            subject
            subject
          }.to change { TransactionType.count }.by(total)
        end
      end

      context 'when a transaction type has been removed from the model' do
        let!(:old_transaction_type) { create :transaction_type, name: :council_tax }
        it 'sets the archived_at date in the database' do
          subject
          expect(TransactionType.find_by(name: 'council_tax').archived_at).to_not eq nil
        end

        it 'does not set the archived_at date in the database for active transaction types' do
          subject
          active_names = names.values.flatten - archived_credit_names
          active_names.each do |transaction_name|
            expect(TransactionType.find_by(name: transaction_name).archived_at).to eq nil
          end
        end
      end
    end

    describe '.call(:without_income)' do
      # this is called from an old migration
      subject { described_class.call(:without_income) }

      it 'does not attempt to update other_income fields' do
        subject
        expect(TransactionType.where(other_income: true).count).to eq 0
      end
    end
  end
end
