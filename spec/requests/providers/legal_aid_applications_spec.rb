require 'rails_helper'

RSpec.describe 'providers legal aid application requests', type: :request do
  describe 'GET /providers/applications' do
    let(:perform_request) { get providers_legal_aid_applications_path }

    it_behaves_like 'a provider not authenticated'

    context 'when the provider is authenticated' do
      let(:provider) { create(:provider) }

      before do
        login_as provider
      end

      it 'returns http success' do
        perform_request
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /providers/applications/new' do
    let(:perform_request) { get new_providers_legal_aid_application_path }

    it_behaves_like 'a provider not authenticated'

    context 'when the provider is authenticated' do
      let(:provider) { create(:provider) }

      before do
        login_as provider
      end

      it 'returns http success' do
        perform_request
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'POST /providers/applications' do
    let!(:proceeding_type) { create(:proceeding_type, code: code) }
    let(:code) { 'PR0001' }
    let(:params) { { proceeding_type: code } }
    let(:perform_request) { post '/providers/applications', params: params }

    it_behaves_like 'a provider not authenticated'

    context 'when the provider is authenticated' do
      let(:provider) { create(:provider) }

      before do
        login_as provider
      end

      it 'creates a new application record' do
        expect { perform_request }.to change { LegalAidApplication.count }.by(1)
      end

      it 'redirects successfully to the next submission step' do
        perform_request

        new_application = LegalAidApplication.last
        expect(response).to redirect_to(providers_legal_aid_application_applicant_path(new_application))
      end

      context 'when the params are not valid' do
        let(:params) { { proceeding_type: 'random-code' } }

        it 'does NOT create a new application record' do
          expect { perform_request }.not_to change { LegalAidApplication.count }
        end

        it 're-renders the proceeding type selection page' do
          perform_request

          expect(unescaped_response_body).to include('What does your client want legal aid for?')
        end
      end
    end
  end
end
