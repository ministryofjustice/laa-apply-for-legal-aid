require 'rails_helper'

RSpec.describe 'providers legal aid application requests', type: :request do
  describe 'GET /providers/applications' do
    before { get providers_legal_aid_applications_path }

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /providers/applications/new' do
    before { get new_providers_legal_aid_application_path }

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /providers/applications' do

    let (:proceeding_type) { 'PR0001' }

    before { post '/providers/applications', params: proceeding_type }

    it 'redirects successfully' do
      expect(response).to redirect_to(new_providers_legal_aid_application_applicant_path)
    end

    it 'renders the next page' do
      expect(response.body).to include("Enter your client's details")
    end
  end
end
