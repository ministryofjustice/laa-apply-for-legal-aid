require 'rails_helper'

RSpec.describe LegalAidApplicationTransactionType, type: :model do
  describe 'relationships' do
    let(:credit_transaction_type) { create :transaction_type, :credit_with_standard_name }
    let(:debit_transaction_type) { create :transaction_type, :debit_with_standard_name }
    let(:legal_aid_application) { create :legal_aid_application }
    before do
      create(
        :legal_aid_application_transaction_type,
        legal_aid_application: legal_aid_application,
        transaction_type: credit_transaction_type
      )
      create(
        :legal_aid_application_transaction_type,
        legal_aid_application: legal_aid_application,
        transaction_type: debit_transaction_type
      )
    end

    describe 'legal_aid_application has_many' do
      it 'returns all' do
        expect(legal_aid_application.transaction_types).to contain_exactly(credit_transaction_type, debit_transaction_type)
      end
    end

    describe 'legal_aid_application credit transaction_types' do
      it 'returns just the credit types' do
        expect(legal_aid_application.transaction_types.credits).to contain_exactly(credit_transaction_type)
      end
    end

    describe 'legal_aid_application debit transaction_types' do
      it 'returns just the debit types' do
        expect(legal_aid_application.transaction_types.debits).to contain_exactly(debit_transaction_type)
      end
    end
  end
end
