require 'rails_helper'

RSpec.describe Providers::BankTransactionsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
  let(:provider) { legal_aid_application.provider }

  describe 'PATCH providers/bank_transactions/:id/remove_transaction_type' do
    let!(:transaction_type) { create :transaction_type }
    let(:bank_provider) { create :bank_provider, applicant: legal_aid_application.applicant }
    let(:bank_account) { create :bank_account, bank_provider: bank_provider }
    let(:bank_transaction) { create :bank_transaction, bank_account: bank_account, transaction_type: transaction_type }
    let(:login) { login_as provider }

    subject do
      patch remove_transaction_type_providers_legal_aid_application_bank_transaction_path(legal_aid_application, bank_transaction)
    end

    before { login }

    context 'when the provider is not authenticated' do
      let(:login) { nil }
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    it 'returns http success' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'does not delete the transaction type' do
      expect { subject }.not_to change { TransactionType.count }
    end

    it 'removes the assocation with the transaction type' do
      expect { subject }.to change { bank_transaction.reload.transaction_type }.to(nil)
    end

    it 'removes the meta data on the transaction' do
      bank_transaction.update(meta_data: { code: 'XXXX',
                                           label: 'manually_chosen',
                                           name: 'Maintenance In',
                                           category: 'Maintenance In',
                                           selected_by: 'Provider' })
      expect { subject }.to change { bank_transaction.reload.meta_data }.to(nil)
    end

    context 'bank_transaction does not belong to this application' do
      let(:bank_account) { create :bank_account }

      it 'does not remove the assocation with the transaction type' do
        expect { subject }.to_not change { bank_transaction.reload.transaction_type }
      end

      it 'redirects to page_not_found' do
        subject
        expect(response).to redirect_to '/error/page_not_found?locale=en'
      end
    end
  end
end
