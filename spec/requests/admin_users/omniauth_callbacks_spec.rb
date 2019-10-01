require 'rails_helper'

RSpec.describe 'admin users omniauth call back', type: :request do
  around(:example) do |example|
    OmniAuth.config.test_mode = true
    example.run
    OmniAuth.config.mock_auth[:true_layer] = nil
    OmniAuth.config.test_mode = false
  end

  let(:token) { SecureRandom.uuid }
  let(:expires_at) { 1.hour.from_now.round }
  let(:google_expires_at) { expires_at.to_i }
  let(:admin_user) { create :admin_user }

  before do
    OmniAuth.config.add_mock(
      :google_oauth2,
      credentials: {
        token: token,
        expires_at: google_expires_at
      }
    )
  end

  describe 'GET /auth/google_oauth2/callback' do
    subject do
      get admin_user_google_oauth2_omniauth_callback_path
    end

    it 'redirects to admin user root' do
      expect(subject).to redirect_to(admin_root_path)
    end
  end

end
