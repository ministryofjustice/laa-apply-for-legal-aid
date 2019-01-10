require 'rails_helper'

RSpec.describe 'does client use online banking requests', type: :request do
  let(:applicant) { create :applicant, uses_online_banking: nil }
  let(:application) { create :legal_aid_application, applicant: applicant }
  let(:application_id) { application.id }
  let(:provider) { application.provider }

  describe 'GET /providers/applications/:legal_aid_application_id/applicant' do
    subject { get "/providers/applications/#{application_id}/does-client-use-online-banking" }

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
        expect(response).to have_http_status(:ok)
      end

      it 'displays the correct page' do
        expect(unescaped_response_body).to include('Does your client use online banking?')
      end

      context 'when the application does not exist' do
        let(:application_id) { SecureRandom.uuid }

        it 'redirects the user to the applications page with an error message' do
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end
      end
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/does-client-use-online-banking' do
    let(:params) do
      {
        applicant: { uses_online_banking: uses_online_banking }
      }
    end
    subject { patch "/providers/applications/#{application_id}/does-client-use-online-banking", params: params }

    context 'when the provider is authenticated' do
      before do
        login_as provider
        subject
      end

      context 'when no option is chosen' do
        let(:params) { nil }

        it 'shows an error' do
          expect(unescaped_response_body).to include('Please select an option')
        end
      end

      context 'when "Yes" is chosen' do
        let(:uses_online_banking) { 'true' }

        it 'updates the applicant' do
          expect(applicant.reload.uses_online_banking).to eq(true)
        end

        it 'redirects to check_provider_answers page' do
          expect(response).to redirect_to(providers_legal_aid_application_about_the_financial_assessment_path(application))
        end
      end

      context 'when "No" is chosen' do
        let(:uses_online_banking) { 'false' }

        it 'updates the applicant' do
          expect(applicant.reload.uses_online_banking).to eq(false)
        end

        it 'tells provider to use CCMS' do
          expect(unescaped_response_body).to include('use CCMS')
        end
      end
    end
  end
end
