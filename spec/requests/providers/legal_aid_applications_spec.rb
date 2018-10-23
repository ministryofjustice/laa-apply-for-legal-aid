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
end
