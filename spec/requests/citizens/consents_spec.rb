require 'rails_helper'

RSpec.describe Applicants::OpenBankingConsentForm, type: :request do
  describe 'citizen consent request test' do
    describe 'GET /citizens/consent' do
      before { get citizens_consent_path }

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
        expect(unescaped_response_body).to include('I agree for you to check')
      end
    end
  end

  describe 'POST /citizens/additional_accounts', type: :request do
    let(:applicant) { create :applicant }
    let(:legal_aid_application) { create :legal_aid_application, applicant: applicant }
    let(:params) { { consent_choice_timestamp: Time.current } }
    before do
      sign_in applicant
      post citizens_consent_path, params: params
    end

    context 'when consent is granted' do
      let(:params) { { legal_aid_application: { open_banking_consent: 'YES' } } }

      it 'redirects to new action' do
        expect(response).to redirect_to(applicant_true_layer_omniauth_authorize_path)
        expect(unescaped_response_body).to include('true')
      end
    end

    context 'when consent is not granted' do
      let(:params) { { legal_aid_application: { open_banking_consent: 'NO' } } }

      it 'redirects to a holding page action' do
        # TODO: add new path
        # expect(response).to redirect_to(to_be_determined_path)
        expect(unescaped_response_body).to include('Landing page: No Consent provided')
      end
    end
  end
end
