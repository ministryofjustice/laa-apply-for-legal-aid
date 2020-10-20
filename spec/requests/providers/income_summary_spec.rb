require 'rails_helper'

RSpec.describe Providers::IncomeSummaryController do
  let!(:salary) { create :transaction_type, :credit, name: 'salary' }
  let!(:benefits) { create :transaction_type, :credit, name: 'benefits' }
  let!(:maintenance) { create :transaction_type, :credit, name: 'maintenance_in' }
  let!(:pension) { create :transaction_type, :credit, name: 'pension' }
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :with_non_passported_state_machine, transaction_types: [salary, benefits] }
  let(:provider) { legal_aid_application.provider }
  let(:login) { login_as provider }

  before do
    login
  end

  describe 'GET /providers/income_summary' do
    subject { get providers_legal_aid_application_income_summary_index_path(legal_aid_application) }

    it 'returns http success' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'displays a section for all transaction types linked to this application' do
      subject
      [salary, benefits].pluck(:name).each do |name|
        legend = I18n.t("transaction_types.names.providers.#{name}")
        expect(parsed_response_body.css("ol li##{name} h2").text).to match(/#{legend}/)
      end
    end

    it 'does not display a section for transaction types not linked to this application' do
      subject
      [maintenance, pension].pluck(:name) do |name|
        expect(parsed_response_body.css("ol li#income-type-#{name} h2").size).to eq 0
      end
    end

    context 'when the provider is not authenticated' do
      let(:login) { nil }
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'not all transaction types selected' do
      it 'displays an Add additional income types section' do
        subject
        expect(response.body).to include(I18n.t('providers.income_summary.add_other_income.add_other_income'))
      end
    end

    context 'all transaction types selected' do
      before do
        legal_aid_application.transaction_types << maintenance
        legal_aid_application.transaction_types << pension
        subject
      end
      it 'does not display an Add additional income types section' do
        expect(response.body).not_to include(I18n.t('providers.income_summary.add_other_income.add_other_income'))
      end
    end

    context 'with assigned (by type) transactions' do
      let(:applicant) { create :applicant }
      let(:bank_provider) { create :bank_provider, applicant: applicant }
      let(:bank_account) { create :bank_account, bank_provider: bank_provider }
      let!(:bank_transaction) { create :bank_transaction, :credit, transaction_type: salary, bank_account: bank_account }
      let(:legal_aid_application) { create :legal_aid_application, :with_non_passported_state_machine, applicant: applicant, transaction_types: [salary] }

      it 'displays bank transaction' do
        subject
        expect(legal_aid_application.bank_transactions).to include(bank_transaction)
        expect(response.body).to include(bank_transaction.description)
      end
    end
  end

  describe 'POST /providers/income_summary' do
    let(:applicant) { create :applicant }
    let(:bank_provider) { create :bank_provider, applicant: applicant }
    let(:bank_account) { create :bank_account, bank_provider: bank_provider }
    let!(:bank_transaction) { create :bank_transaction, :credit, transaction_type: salary, bank_account: bank_account }
    let(:legal_aid_application) { create :legal_aid_application, :with_non_passported_state_machine, applicant: applicant, transaction_types: [salary] }

    let(:submit_button) { { continue_button: 'Continue' } }
    subject { post providers_legal_aid_application_income_summary_index_path(legal_aid_application), params: submit_button }
    before { subject }

    it 'redirects to the next page' do
      expect(response).to redirect_to(providers_legal_aid_application_has_dependants_path(legal_aid_application))
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
      let!(:bank_transaction) { create :bank_transaction, :credit, transaction_type: nil, bank_account: bank_account }
      let(:legal_aid_application) { create :legal_aid_application, :with_non_passported_state_machine, applicant: applicant, transaction_types: [salary] }

      let(:submit_button) { { continue_button: 'Continue' } }
      subject { post providers_legal_aid_application_income_summary_index_path(legal_aid_application), params: submit_button }
      before { subject }

      it 'renders successfully' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns errors' do
        expect(response.body).to include(I18n.t('activemodel.errors.models.legal_aid_application.attributes.uncategorised_bank_transactions.message'))
      end
    end

    context 'no disregarded benefits are categorised' do
      let(:excluded_benefits) { create :transaction_type, :credit, name: 'excluded_benefits' }
      let(:legal_aid_application) { create :legal_aid_application, :with_non_passported_state_machine, applicant: applicant, transaction_types: [excluded_benefits] }

      it 'does not return an error' do
        expect(response.body).not_to include(I18n.t('activemodel.errors.models.legal_aid_application.attributes.uncategorised_bank_transactions.message'))
      end
    end
  end
end
