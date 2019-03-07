require 'rails_helper'

RSpec.describe Citizens::TransactionsController, type: :request do
  include ActionView::Helpers::NumberHelper
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
  let(:applicant) { legal_aid_application.applicant }
  let(:secure_id) { legal_aid_application.generate_secure_id }
  let(:transaction_type) { create :transaction_type }
  let(:bank_provider) { create :bank_provider, applicant: applicant }
  let(:bank_account) { create :bank_account, bank_provider: bank_provider }

  before do
    get citizens_legal_aid_application_path(secure_id)
  end

  describe 'GET #citizens/transactions' do
    subject { get citizens_transactions_path(transaction_type: transaction_type.name) }

    it 'returns http success' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'renders the transactions page' do
      subject
      expect(unescaped_response_body).to include(I18n.t("transaction_types.page_titles.#{transaction_type.name}"))
    end

    context 'When there are transactions' do
      let(:not_matching_operation) { (TransactionType::NAMES.keys.map(&:to_s) - [transaction_type.operation.to_s]).first }
      let(:other_transaction_type) { create :transaction_type, name: (TransactionType::NAMES[transaction_type.operation.to_sym] - [transaction_type.name.to_sym]).sample }
      let!(:bank_transaction_matching) { create :bank_transaction, bank_account: bank_account, operation: transaction_type.operation }
      let!(:bank_transaction_selected) { create :bank_transaction, bank_account: bank_account, operation: transaction_type.operation, transaction_type: transaction_type }
      let!(:bank_transaction_not_matching) { create :bank_transaction, bank_account: bank_account, operation: not_matching_operation }
      let!(:bank_transaction_other_applicant) { create :bank_transaction, operation: transaction_type.operation }
      let!(:bank_transaction_other_type) { create :bank_transaction, bank_account: bank_account, operation: transaction_type.operation, transaction_type: other_transaction_type }

      it 'shows the transactions matching the operation on the transaction type' do
        subject
        expect(unescaped_response_body).to include(bank_transaction_matching.description)
        expect(unescaped_response_body).to include(bank_transaction_selected.description)
      end

      it 'shows the transaction date' do
        subject
        expect(unescaped_response_body).to include(bank_transaction_matching.happened_at.to_date.strftime(I18n.t('date.formats.short_date')))
      end

      it 'shows the transaction amount' do
        subject
        transaction = bank_transaction_matching
        expected_amount = number_to_currency(transaction.amount, unit: I18n.t("currency.#{transaction.currency.downcase}", default: transaction.currency))
        expect(unescaped_response_body).to include(expected_amount)
      end

      it 'shows selected transactions' do
        subject
        checkbox = parsed_response_body.at_css("[value='#{bank_transaction_selected.id}']")
        expect(checkbox[:checked]).to eq('checked')
      end

      it 'does not show transactions that do not match the operation on the transaction type' do
        subject
        expect(unescaped_response_body).not_to include(bank_transaction_not_matching.description)
      end

      it 'does not show other applicants transactions' do
        subject
        expect(unescaped_response_body).not_to include(bank_transaction_other_applicant.description)
      end

      it 'does not show checkboxes for transactions already assigned to another transaction type' do
        subject
        checkbox = parsed_response_body.at_css("[value='#{bank_transaction_other_type.id}']")
        expect(checkbox).to be_nil
        expect(unescaped_response_body).to include(bank_transaction_other_type.description)
      end
    end

    describe 'PATCH #citizens/transactions' do
      let!(:bank_transaction_A) { create :bank_transaction, bank_account: bank_account, operation: transaction_type.operation, transaction_type: transaction_type }
      let!(:bank_transaction_B) { create :bank_transaction, bank_account: bank_account, operation: transaction_type.operation }
      let!(:bank_transaction_other_applicant) { create :bank_transaction, operation: transaction_type.operation }
      let(:selected_transactions) { [bank_transaction_B, bank_transaction_other_applicant] }
      let(:params) do
        {
          transaction_type: transaction_type.name,
          transaction_ids: selected_transactions.pluck(:id)
        }
      end

      subject { patch citizens_transactions_path(params) }

      it 'unselect the previously selected' do
        expect { subject }.to change { bank_transaction_A.reload.transaction_type }.to(nil)
      end

      it 'saves the selected transactions' do
        expect { subject }.to change { bank_transaction_B.reload.transaction_type }.from(nil).to(transaction_type)
      end

      it 'does not change other applicants transactions' do
        expect { subject }.not_to change { bank_transaction_other_applicant.reload.transaction_type }
      end

      it 'redirects to the next page' do
        subject
        expect(response).to redirect_to citizens_income_summary_index_path
        follow_redirect!
        expect(response.body).to include('Select your income')
      end
    end
  end
end
