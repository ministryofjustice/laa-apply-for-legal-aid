require 'rails_helper'

module CashTransactions
  RSpec.describe Income do
    describe 'validations' do
      let(:legal_aid_application) { create :legal_aid_application }
      let(:income_transaction_type) { create :transaction_type, :credit }
      let(:outgoings_transaction_type) { create :transaction_type, :debit }

      subject do
        Income.create!(
          legal_aid_application: legal_aid_application,
          transaction_type: transaction_type,
          amount: amount
        )
      end

      context 'transaction type is debit' do
        let(:transaction_type) { outgoings_transaction_type }
        let(:amount) { 277.44 }
        it 'errors' do
          expect { subject }.to raise_error ActiveRecord::RecordInvalid, 'Validation failed: Transaction type must be credit'
        end
      end

      context 'nil amount' do
        let(:transaction_type) { income_transaction_type }
        let(:amount) { nil }
        it 'errors' do
          expect { subject }.to raise_error ActiveRecord::RecordInvalid, "Validation failed: Amount can't be blank"
        end
      end

      context 'valid' do
        let(:transaction_type) { income_transaction_type }
        let(:amount) { 55.44 }
        it 'saves successfully' do
          expect { subject }.to change { Income.count }.by(1)
        end
      end
    end
  end
end
