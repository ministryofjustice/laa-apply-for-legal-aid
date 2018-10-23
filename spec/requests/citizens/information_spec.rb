require 'rails_helper'

RSpec.describe 'citizen consents request test', type: :request do
  describe 'GET /citizens/consent' do
    before { get citizens_consent_path }

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end
  end
end
