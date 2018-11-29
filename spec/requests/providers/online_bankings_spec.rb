require 'rails_helper'

RSpec.describe 'does client use online banking requests', type: :request do
  let(:applicant) { create :applicant }
  let(:application) { create :legal_aid_application, applicant: applicant }
  let(:application_id) { application.id }

  describe 'GET /providers/applications/:legal_aid_application_id/applicant' do
    let(:get_request) { get "/providers/applications/#{application_id}/does-client-use-online-banking" }

    it 'returns http success' do
      get_request
      expect(response).to have_http_status(:ok)
    end

    context 'when the application does not exist' do
      let(:application_id) { SecureRandom.uuid }

      it 'redirects the user to the applications page with an error message' do
        get_request
        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end
    end

    it 'displays the correct page' do
      get_request
      expect(unescaped_response_body).to include('Does your client use online banking?')
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/applicant' do
    let(:params) do
      {
        applicant: { uses_online_banking: uses_online_banking }
      }
    end
    let(:patch_request) { patch "/providers/applications/#{application_id}/does-client-use-online-banking", params: params }

    context 'when no option is chosen' do
      let(:params) { nil }

      it 'shows an error' do
        patch_request
        expect(unescaped_response_body).to include('Please select an option')
      end
    end

    context 'when "Yes" is chosen' do
      let(:uses_online_banking) { 'true' }

      it 'updates the applicant' do
        patch_request
        expect(applicant.reload.uses_online_banking).to eq(true)
      end

      it 'redirects to check_provider_answers page' do
        patch_request
        expect(response).to redirect_to(providers_legal_aid_application_check_provider_answers_path(application))
      end
    end

    context 'when "No" is chosen' do
      let(:uses_online_banking) { 'false' }

      it 'updates the applicant' do
        patch_request
        expect(applicant.reload.uses_online_banking).to eq(false)
      end

      it 'tells provider to use CCMS' do
        patch_request
        expect(unescaped_response_body).to include('use CCMS')
      end
    end
  end
end
