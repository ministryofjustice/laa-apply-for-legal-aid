require 'rails_helper'

RSpec.describe 'does client use online banking requests', type: :request do
  let(:applicant) { create :applicant, uses_online_banking: nil }
  let(:application) { create :legal_aid_application, applicant: applicant }
  let(:application_id) { application.id }

  describe 'GET /providers/applications/:legal_aid_application_id/does-client-use-online-banking' do
    subject { get "/providers/applications/#{application_id}/does-client-use-online-banking" }

    it 'returns http success' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'displays the correct page' do
      subject
      expect(unescaped_response_body).to include('Does your client use online banking?')
    end

    context 'when the application does not exist' do
      let(:application_id) { SecureRandom.uuid }

      it 'redirects the user to the applications page with an error message' do
        subject
        expect(response).to redirect_to(providers_legal_aid_applications_path)
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

    context 'when no option is chosen' do
      let(:params) { nil }

      it 'shows an error' do
        subject
        expect(unescaped_response_body).to include('Please select an option')
      end
    end

    context 'when "Yes" is chosen' do
      let(:uses_online_banking) { 'true' }

      it 'updates the applicant' do
        subject
        expect(applicant.reload.uses_online_banking).to eq(true)
      end

      it 'redirects to check_provider_answers page' do
        subject
        expect(response).to redirect_to(providers_legal_aid_application_about_the_financial_assessment_path(application))
      end
    end

    context 'when "No" is chosen' do
      let(:uses_online_banking) { 'false' }

      it 'updates the applicant' do
        subject
        expect(applicant.reload.uses_online_banking).to eq(false)
      end

      it 'tells provider to use CCMS' do
        subject
        expect(unescaped_response_body).to include('use CCMS')
      end
    end
  end
end
