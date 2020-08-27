require 'rails_helper'

RSpec.describe Providers::ClientBankAccountsController, type: :request do
  let(:applicant) { create :applicant }
  let(:bank_provider) { create :bank_provider, applicant: applicant }
  let(:bank_account) { create :bank_account, bank_provider: bank_provider }
  let(:legal_aid_application) { create :legal_aid_application, :with_non_passported_state_machine, applicant: applicant }
  let!(:savings_amount) { create :savings_amount }
  let(:application_id) { legal_aid_application.id }
  let!(:provider) { legal_aid_application.provider }

  describe 'GET providers/client_bank_account' do
    # subject { get providers_legal_aid_application_client_bank_account_path(legal_aid_application.id) }
    subject { get "/providers/applications/#{application_id}/client_bank_account" }

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      before do
        login_as provider
        subject
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'displays the correct page content' do
        expect(unescaped_response_body).to include(I18n.t('providers.client_bank_accounts.show.heading'))
        expect(unescaped_response_body).to include(I18n.t('providers.client_bank_accounts.show.offline_savings_accounts'))
      end

      it 'shows the client bank account name and balance' do
        expect(response).to include
      end
    end
  end
end
