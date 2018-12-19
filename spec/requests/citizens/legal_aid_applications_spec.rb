require 'rails_helper'

RSpec.describe 'citizen home requests', type: :request do
  let(:application) { create :application, :with_applicant }
  let(:application_id) { application.id }
  let(:secure_id) { application.generate_secure_id }
  let(:applicant_first_name) { application.applicant.first_name }
  let(:applicant_last_name) { application.applicant.last_name }

  describe 'GET #citizens/applications/:id' do
    before { get citizens_legal_aid_application_path(secure_id) }

    context 'when there is a legal aid application that matches the secure data' do
      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'sets the application_ref session variable' do
        expect(session[:current_application_ref]).to eq(application_id)
      end

      it 'returns the correct application' do
        expect(response.body).to include(CGI.escapeHTML(applicant_first_name.html_safe))
        expect(response.body).to include(CGI.escapeHTML(applicant_last_name.html_safe))
      end
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
end
