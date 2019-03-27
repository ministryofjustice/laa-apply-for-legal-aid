require 'rails_helper'

RSpec.describe Providers::MeansSummariesController, type: :request do
  let(:provider) { create :provider }
  let(:applicant) { create :applicant }
  let(:transaction_type) { create :transaction_type }
  let(:bank_provider) { create :bank_provider, applicant: applicant }
  let(:bank_account) { create :bank_account, bank_provider: bank_provider }
  let(:legal_aid_application) do
    create :legal_aid_application, applicant: applicant, provider: provider, transaction_types: [transaction_type], state: :means_completed
  end
  let(:login) { login_as provider }

  describe 'GET /providers/applications/:legal_aid_application_id/means_summary' do
    let!(:bank_transactions) { create_list :bank_transaction, 3, transaction_type: transaction_type, bank_account: bank_account }

    subject { get providers_legal_aid_application_means_summary_path(legal_aid_application) }

    before do
      login
      subject
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'displays the bank transaction data' do
      total_amount = bank_transactions.sum(&:amount)
      expect(total_amount).not_to be_zero
      expect(response.body).to include(ActiveSupport::NumberHelper.number_to_currency(total_amount))
    end

    context 'when not logged in' do
      let(:login) {}
      it_behaves_like 'a provider not authenticated'
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/means_summary' do
    let(:params) { {} }
    subject { patch providers_legal_aid_application_means_summary_path(legal_aid_application), params: params }

    before do
      login
      subject
    end

    it 'redirects to next page' do
      expect(response).to redirect_to flow_forward_path
    end

    context 'when submitted as draft' do
      let(:params) do
        { draft_button: 'Save as draft' }
      end

      it 'displays the providers applications page' do
        expect(response).to redirect_to providers_legal_aid_applications_path
      end

      it 'sets the application as draft' do
        expect(legal_aid_application.reload).to be_draft
      end
    end

    context 'when not logged in' do
      let(:login) {}
      it_behaves_like 'a provider not authenticated'
    end
  end
end
