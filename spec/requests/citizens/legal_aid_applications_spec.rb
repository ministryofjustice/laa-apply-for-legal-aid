require 'rails_helper'

RSpec.describe 'citizen home requests', type: :request do
  let(:application) { create :application, :with_applicant }
  let(:application_id) { application.id }
  let(:secure_id) { application.generate_secure_id }
  let(:applicant_first_name) { application.applicant.first_name }
  let(:applicant_last_name) { application.applicant.last_name }

  describe 'GET citizens/applications/:id' do
    before { get citizens_legal_aid_application_path(secure_id) }

    it 'redirects to applications' do
      expect(response).to redirect_to(citizens_legal_aid_applications_path)
    end

    context 'when no matching legal aid application exists' do
      let(:secure_id) { SecureRandom.uuid }

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'show a landing page' do
        expect(response.body).to match('Authentication failed')
      end
    end
  end

  describe 'GET citizens/applications' do
    subject do
      get citizens_legal_aid_application_path(secure_id)
      get citizens_legal_aid_applications_path
    end

    context 'when there is a legal aid application that matches the secure data' do
      it 'returns http success' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'sets the application_id session variable' do
        subject
        expect(session[:current_application_id]).to eq(application_id)
      end

      it 'returns the correct application' do
        subject
        expect(unescaped_response_body).to include(applicant_first_name.html_safe)
        expect(unescaped_response_body).to include(applicant_last_name.html_safe)
      end

      context 'if a provider is logged in' do
        let(:provider) { create :provider }
        before { sign_in provider }

        it 'logs out the provider' do
          subject
          expect(unescaped_response_body).not_to include(provider.username)
        end
      end
    end
  end
end
