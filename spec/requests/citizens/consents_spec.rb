require 'rails_helper'

RSpec.describe Citizens::ConsentsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }
  describe 'GET /citizens/consent' do
    before do
      get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
      get citizens_consent_path
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
      expect(unescaped_response_body).to include('I agree for you to check')
    end
  end

  describe 'POST /citizens/consent', type: :request do
    before do
      get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
      post citizens_consent_path, params: params
    end

    context 'when consent is granted' do
      let(:params) { { legal_aid_application: { open_banking_consent: 'true' } } }

      it 'redirects to new action' do
        expect(response).to redirect_to(citizens_banks_path)
      end

      it 'records the decision on the legal aid application' do
        legal_aid_application.reload
        expect(legal_aid_application.open_banking_consent).to eq(true)
        expect(legal_aid_application.open_banking_consent_choice_at.to_s(be_between(2.seconds.ago, 1.second.from_now)))
      end
    end

    context 'when consent is not granted' do
      let(:params) { { legal_aid_application: { open_banking_consent: 'false' } } }

      it 'redirects to a holding page action' do
        # TODO: add new path
        # expect(response).to redirect_to(to_be_determined_path)
        expect(unescaped_response_body).to include('Landing page: No Consent provided')
      end

      it 'records the decision on the legal aid application' do
        legal_aid_application.reload
        expect(legal_aid_application.open_banking_consent).to eq(false)
        expect(legal_aid_application.open_banking_consent_choice_at.to_s(be_between(2.seconds.ago, 1.second.from_now)))
      end
    end
  end
end
