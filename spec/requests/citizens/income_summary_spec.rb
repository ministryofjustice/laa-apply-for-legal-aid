require 'rails_helper'

RSpec.describe Citizens::IncomeSummaryController do
  let!(:salary) { create :transaction_type, :credit, name: 'salary' }
  let!(:benefits) { create :transaction_type, :credit, name: 'benefits' }
  let!(:maintenance) { create :transaction_type, :credit, name: 'maintenance_in' }
  let!(:pension) { create :transaction_type, :credit, name: 'pension' }
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant, transaction_types: [salary, benefits] }
  let(:secure_id) { legal_aid_application.generate_secure_id }

  before do
    get citizens_legal_aid_application_path(secure_id)
  end

  describe 'GET /citizens/income_summary' do
    subject { get citizens_income_summary_index_path }

    it 'returns http success' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'displays a section for all transaction types linked to this application' do
      subject
      [salary, benefits].pluck(:name).each do |name|
        legend = I18n.t("transaction_types.names.#{name}")
        expect(parsed_response_body.css("ol li#income-type-#{name} h2").text).to match(/#{legend}/)
      end
    end

    it 'does not display a section for transaction types not linked to this application' do
      subject
      [maintenance, pension].pluck(:name) do |name|
        expect(parsed_response_body.css("ol li#income-type-#{name} h2").size).to eq 0
      end
    end

    context 'not all transaction types selected' do
      it 'displays an Add additional income types section' do
        subject
        expect(response.body).to include(I18n.t('citizens.income_summary.add_other_income.add_other_income'))
      end
    end

    context 'all transaction types selected' do
      before do
        legal_aid_application.transaction_types << maintenance
        legal_aid_application.transaction_types << pension
        subject
      end
      it 'does not display an Add additional income types section' do
        expect(response.body).not_to include(I18n.t('citizens.income_summaries.add_other_income.add_other_income'))
      end
    end

    context 'with assigned (by type) transactions' do
      let(:applicant) { create :applicant }
      let(:bank_provider) { create :bank_provider, applicant: applicant }
      let(:bank_account) { create :bank_account, bank_provider: bank_provider }
      let!(:bank_transaction) { create :bank_transaction, :credit, transaction_type: salary, bank_account: bank_account }
      let(:legal_aid_application) { create :legal_aid_application, applicant: applicant, transaction_types: [salary] }

      it 'displays bank transaction' do
        subject
        expect(legal_aid_application.bank_transactions).to include(bank_transaction)
        expect(response.body).to include(bank_transaction.description)
      end
    end
  end
end
