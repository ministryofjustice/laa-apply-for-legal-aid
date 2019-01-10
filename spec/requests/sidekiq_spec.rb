require 'rails_helper'

RSpec.describe 'sidekiq WEB UI', type: :request do
  describe 'GET /sidekiq' do
    it 'returns unauthorized status' do
      get sidekiq_web_path

      expect(response).to have_http_status(:unauthorized)
    end

    context 'with the right authentication' do
      it 'is successful' do
        username = 'sidekiq'
        password = ENV['SIDEKIQ_WEB_UI_PASSWORD']
        get sidekiq_web_path, headers: {
          'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
        }
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
