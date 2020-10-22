require 'rails_helper'

RSpec.describe Providers::OutgoingsSummaryController, type: :request do
  let(:transaction_type) { create :transaction_type, :debit_with_standard_name }
  let(:other_transaction_type) { create :transaction_type, :debit_with_standard_name }
  let!(:legal_aid) { create :transaction_type, :debit, name: 'legal_aid' }
  let(:legal_aid_application) do
    create(
      :legal_aid_application,
      :with_applicant,
      :with_transaction_period,
      :with_non_passported_state_machine,
      transaction_types: [transaction_type]
    )
  end
  let(:provider) { legal_aid_application.provider }
  let(:login) { login_as provider }

  before do
    TransactionType.delete_all
    other_transaction_type
    login
  end

  describe 'GET /providers/outgoings_summary' do
    subject { get providers_legal_aid_application_outgoings_summary_index_path(legal_aid_application) }

    context 'when the provider is not authenticated' do
      let(:login) { nil }
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    it 'returns http success' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'displays a section for all transaction types linked to this application' do
      subject
      name = transaction_type.name
      legend = I18n.t("transaction_types.names.providers.#{name}")
      expect(parsed_response_body.css("ol li##{name}").text).to match(/#{legend}/)
    end

    it 'does not display a section for transaction types not linked to this application' do
      subject
      expect(parsed_response_body.css("ol li h2#outgoing-type-#{other_transaction_type.name}").size).to be_zero
    end

    context 'not all transaction types selected' do
      it 'displays an Add additional outgoings types section' do
        subject
        expect(response.body).to include(I18n.t('providers.outgoings_summary.add_other_outgoings.add_other_outgoings'))
      end
    end

    context 'all transaction types selected' do
      let(:legal_aid_application) do
        create(
          :legal_aid_application,
          :with_applicant,
          :with_non_passported_state_machine,
          transaction_types: [transaction_type, other_transaction_type]
        )
      end
      it 'does not display an Add additional outgoing types section' do
        get providers_legal_aid_application_outgoings_summary_index_path(legal_aid_application)
        expect(response.body).not_to include(I18n.t('citizens.outgoings_summary.add_other_outgoings.add_other_outgoings'))
      end
    end

    context 'with assigned (by type) transactions' do
      let(:applicant) { create :applicant }
      let(:bank_provider) { create :bank_provider, applicant: applicant }
      let(:bank_account) { create :bank_account, bank_provider: bank_provider }
      let(:transaction_type) { create :transaction_type, :debit }
      let!(:bank_transaction) { create :bank_transaction, :debit, transaction_type: transaction_type, bank_account: bank_account }
      let(:legal_aid_application) { create :legal_aid_application, :with_non_passported_state_machine, applicant: applicant, transaction_types: [transaction_type] }

      it 'displays bank transaction' do
        subject
        expect(legal_aid_application.bank_transactions).to include(bank_transaction)
        expect(response.body).to include(bank_transaction.description)
      end

      it 'displays a link to add more transaction of this type' do
        subject
        path = providers_legal_aid_application_outgoing_transactions_path(legal_aid_application, transaction_type: transaction_type.name)
        expect(response.body).to include(path)
      end
    end
  end

  describe 'POST /providers/income_summary' do
    let(:applicant) { create :applicant }
    let(:bank_provider) { create :bank_provider, applicant: applicant }
    let(:bank_account) { create :bank_account, bank_provider: bank_provider }
    let!(:bank_transaction) { create :bank_transaction, :debit, transaction_type: transaction_type, bank_account: bank_account }
    let(:legal_aid_application) { create :legal_aid_application, :with_non_passported_state_machine, applicant: applicant, transaction_types: [transaction_type] }

    let(:submit_button) { { continue_button: 'Continue' } }
    subject { post providers_legal_aid_application_outgoings_summary_index_path(legal_aid_application), params: submit_button }
    before { subject }

    it 'redirects to the next page' do
      expect(response).to redirect_to(providers_legal_aid_application_own_home_path(legal_aid_application))
    end

    context 'when the provider is not authenticated' do
      let(:login) { nil }
      it_behaves_like 'a provider not authenticated'
    end

    context 'Form submitted with Save as draft button' do
      let(:submit_button) { { draft_button: 'Save as draft' } }

      it 'redirects to the list of applications' do
        expect(response).to redirect_to providers_legal_aid_applications_path
      end
    end

    context 'The transaction type category has no bank transactions' do
      let(:applicant) { create :applicant }
      let(:bank_provider) { create :bank_provider, applicant: applicant }
      let(:bank_account) { create :bank_account, bank_provider: bank_provider }
      let!(:bank_transaction) { create :bank_transaction, :debit, transaction_type: nil, bank_account: bank_account }
      let(:transaction_type) { create :transaction_type, :debit }
      let(:legal_aid_application) { create :legal_aid_application, :with_non_passported_state_machine, applicant: applicant, transaction_types: [transaction_type] }

      let(:submit_button) { { continue_button: 'Continue' } }
      subject { post providers_legal_aid_application_outgoings_summary_index_path(legal_aid_application), params: submit_button }
      before { subject }

      it 'renders successfully' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns errors' do
        expect(response.body).to include(I18n.t('activemodel.errors.models.legal_aid_application.attributes.uncategorised_bank_transactions.message'))
      end
    end
  end
end
