require 'rails_helper'

RSpec.describe 'provider start of journey test', type: :request do
  describe 'GET /providers' do
    before { get providers_root_path }

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end
  end
end
