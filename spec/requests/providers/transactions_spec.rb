require 'rails_helper'
require Rails.root.join('spec/factories/cfe_results/state_benefit_types/mock_state_benefit_type_result')

RSpec.describe Providers::TransactionsController, type: :request do
  include ActionView::Helpers::NumberHelper
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :with_transaction_period }
  let(:applicant) { legal_aid_application.applicant }
  let(:provider) { legal_aid_application.provider }
  let(:transaction_type) { create :transaction_type }
  let(:bank_provider) { create :bank_provider, applicant: applicant }
  let(:bank_account) { create :bank_account, bank_provider: bank_provider }
  let(:cfe_state_benefits_url) { "#{Rails.configuration.x.check_financial_eligibility_host}/state_benefit_type" }
  let(:cfe_state_benefit_response) { CFE::MockStateBenefitTypeResult.full_list.to_json }

  before do
    login_as provider
    stub_request(:get, cfe_state_benefits_url).to_return(body: cfe_state_benefit_response)
  end

  shared_examples_for 'GET #providers/transactions' do
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
        expected_amount = gds_number_to_currency(transaction.amount, unit: I18n.t("currency.#{transaction.currency.downcase}", default: transaction.currency))
        expect(unescaped_response_body).to include(expected_amount)
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
  end

  describe 'GET #providers/incoming_transactions' do
    subject { get providers_legal_aid_application_incoming_transactions_path(legal_aid_application, transaction_type: transaction_type.name) }

    it_behaves_like 'GET #providers/transactions'

    context 'when the call to Check Financial Eligibility Service for excluded benefits' do
      let(:transaction_type) { create :transaction_type, :excluded_benefits }

      context 'is successful' do
        it_behaves_like 'GET #providers/transactions'
      end

      context 'is un-successful' do
        before { allow(CFE::ObtainStateBenefitTypesService).to receive(:call).and_raise(StandardError) }

        it 'redirects to the problem path as it cannot show the list of excluded benefits' do
          subject

          expect(response).to redirect_to(problem_index_path)
        end
      end
    end
  end

  describe 'GET #citizens/outgoing_transactions' do
    subject { get providers_legal_aid_application_outgoing_transactions_path(legal_aid_application, transaction_type: transaction_type.name) }

    it_behaves_like 'GET #providers/transactions'
  end

  shared_examples_for 'PATCH #providers/transactions' do
    it 'saves the selected transactions' do
      expect { subject }.to change { bank_transaction_B.reload.transaction_type }.from(nil).to(transaction_type)
    end

    it 'does not change other applicants transactions' do
      expect { subject }.not_to change { bank_transaction_other_applicant.reload.transaction_type }
    end
  end

  describe 'updating transactions' do
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

    describe 'PATCH #providers/incoming_transactions' do
      subject { patch providers_legal_aid_application_incoming_transactions_path(legal_aid_application, params) }

      it_behaves_like 'PATCH #providers/transactions'

      context 'when being set to benefits' do
        let!(:benefits_transaction_type) { create :transaction_type, :benefits }
        let!(:selected_transactions) { [bank_transaction_B, bank_transaction_other_applicant, benefit_bank_transaction] }
        let!(:benefit_bank_transaction) { create :bank_transaction, :benefits, bank_account: bank_account, meta_data: nil }
        let(:params) do
          {
            transaction_type: benefits_transaction_type.name,
            transaction_ids: selected_transactions.pluck(:id)
          }
        end

        it 'sets meta_data for benefit transactions' do
          expect { subject }.to change { benefit_bank_transaction.reload.meta_data }.from(nil).to(manually_chosen_metadata)
        end

        def manually_chosen_metadata
          {
            code: 'XXXX',
            label: 'manually_chosen',
            name: 'Benefits',
            category: 'Benefits',
            selected_by: 'Provider'
          }
        end
      end

      context 'when there are identified benefits' do
        let!(:benefits_transaction_type) { create :transaction_type, :benefits }
        let!(:selected_transactions) { [bank_transaction_B, bank_transaction_other_applicant, benefit_bank_transaction, child_benefit_bank_transaction] }
        let!(:benefit_bank_transaction) { create :bank_transaction, :benefits, bank_account: bank_account, meta_data: nil }
        let!(:child_benefit_bank_transaction) do
          create :bank_transaction, :benefits, bank_account: bank_account, meta_data: { code: 'CHB', label: 'child_benefit', name: 'Child Benefit' }
        end
        let(:params) do
          {
            transaction_type: benefits_transaction_type.name,
            transaction_ids: selected_transactions.pluck(:id)
          }
        end

        it 'does not change the meta data for the pre-analysed data' do
          expect { subject }.not_to change { child_benefit_bank_transaction.reload.meta_data }
        end
      end

      context 'when being set to friends_or_family' do
        let!(:friends_or_family_transaction_type) { create :transaction_type, :friends_or_family }
        let!(:selected_transactions) { [bank_transaction_B, bank_transaction_other_applicant, friends_or_family_bank_transaction] }
        let!(:friends_or_family_bank_transaction) { create :bank_transaction, :friends_or_family, bank_account: bank_account, meta_data: nil }
        let(:params) do
          {
            transaction_type: friends_or_family_transaction_type.name,
            transaction_ids: selected_transactions.pluck(:id)
          }
        end

        it 'sets meta_data for friends_or_family transactions' do
          expect { subject }.to change { friends_or_family_bank_transaction.reload.meta_data }.from(nil).to(manually_chosen_metadata)
        end

        def manually_chosen_metadata
          {
            code: 'XXXX',
            label: 'manually_chosen',
            name: 'Friends Or Family',
            category: 'Friends Or Family',
            selected_by: 'Provider'
          }
        end
      end

      it 'redirects to the next page' do
        subject
        expect(response).to redirect_to providers_legal_aid_application_income_summary_index_path
        follow_redirect!
        expect(unescaped_response_body).to include("Sort your client's income into categories")
      end
    end

    describe 'PATCH #providers/outgoing_transactions' do
      subject { patch providers_legal_aid_application_outgoing_transactions_path(legal_aid_application, params) }

      it_behaves_like 'PATCH #providers/transactions'

      context 'when being set to rent' do
        let!(:outgoing_bank_transaction_type) { create :transaction_type, :rent_or_mortgage }
        let!(:selected_transactions) { [bank_transaction_B, bank_transaction_other_applicant, outgoing_bank_transaction] }
        let!(:outgoing_bank_transaction) { create :bank_transaction, :rent_or_mortgage, bank_account: bank_account, meta_data: nil }
        let(:params) do
          {
            transaction_type: outgoing_bank_transaction_type.name,
            transaction_ids: selected_transactions.pluck(:id)
          }
        end

        it 'sets meta_data for outgoing transactions' do
          expect { subject }.to change { outgoing_bank_transaction.reload.meta_data }.from(nil).to(manually_chosen_metadata)
        end

        def manually_chosen_metadata
          {
            code: 'XXXX',
            label: 'manually_chosen',
            name: 'Rent Or Mortgage',
            category: 'Rent Or Mortgage',
            selected_by: 'Provider'
          }
        end
      end

      it 'redirects to the next page' do
        subject
        expect(response).to redirect_to providers_legal_aid_application_outgoings_summary_index_path
        follow_redirect!
        expect(unescaped_response_body).to include(I18n.t('providers.outgoings_summary.index.page_heading'))
      end
    end
  end
end
