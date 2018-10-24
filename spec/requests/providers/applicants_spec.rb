require 'rails_helper'

RSpec.describe 'providers applicant requests', type: :request do

  let(:application_id) { SecureRandom.uuid }
  let(:application) { LegalAidApplication.new id: application_id, applicant: nil }

  describe 'GET /providers/applications/:legal_aid_application_id/applicant/new' do
    it 'returns http success' do
      get "/providers/applications/#{application_id}/applicant/new"
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /providers/applications/:legal_aid_application_id/applicant' do
    it 'returns http success' do
      post "/providers/applications/#{application_id}/applicant"
      expect(response).to have_http_status(:ok)
    end

    it 'redirects successfully' do
      post "/providers/applications/#{application_id}/applicant"
      expect(response).to redirect_to(edit_providers_legal_aid_application_applicant_path)
    end
  end

  describe 'GET /providers/applications/:legal_aid_application_id/applicant/edit' do
    it 'returns http success' do
      get "/providers/applications/#{application_id}/applicant/edit"
      expect(response).to have_http_status(:ok)
    end

    it 'renders the next page' do
      get "/providers/applications/#{application_id}/applicant/edit"
      expect(response.body).to include("What is your client's email address?")
    end
  end
end
