require 'rails_helper'

RSpec.describe 'offline savings accounts', type: :request do
  let(:application) { create :legal_aid_application, :non_passported }
  let(:application_id) { application.id }
  let(:provider) { application.provider }

  describe 'GET /providers/applications/:legal_aid_application_id/offline_savings_account' do
    subject { get "/providers/applications/#{application_id}/offline_savings_account" }

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      before do
        login_as provider
      end

      it 'returns http success' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'displays the offline savings accounts question' do
        subject
        expect(response.body).to include(I18n.t('providers.offline_savings_accounts.show.h1-heading'))
      end
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/offline_savings_account' do
    subject { patch "/providers/applications/#{application_id}/offline_savings_account", params: params }

    let(:application) { create :legal_aid_application, :non_passported }
    let(:provider) { application.provider }
    let(:params) do
      {
        savings_amount: {
          offline_savings_accounts: rand(1...1_000_000.0).round(2)
        }
      }
    end

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      before do
        login_as provider
      end

      context 'Continue button pressed' do
        let(:submit_button) { { continue_button: 'Continue' } }

        it 'redirects to next page' do
          subject
          expect(response.body).to redirect_to(providers_legal_aid_application_savings_and_investment_path(application_id))
        end
      end
    end
  end
end
