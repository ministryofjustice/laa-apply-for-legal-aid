require 'rails_helper'

RSpec.describe 'applicants omniauth call back', type: :request do
  around(:example) do |example|
    OmniAuth.config.test_mode = true
    example.run
    OmniAuth.config.mock_auth[:true_layer] = nil
    OmniAuth.config.test_mode = false
  end

  let(:token) { SecureRandom.uuid }
  let(:expires_at) { 1.hour.from_now.round }
  let(:true_layer_expires_at) { expires_at.to_i }
  let(:applicant) { create :applicant }

  before do
    sign_in applicant if applicant
    OmniAuth.config.add_mock(
      :true_layer,
      credentials: {
        token: token,
        expires_at: true_layer_expires_at
      }
    )
  end

  describe 'GET /applicants/auth/true_layer/callback' do
    subject { get applicant_true_layer_omniauth_callback_path }

    it 'should redirect to next page' do
      expect(subject).to redirect_to(citizens_accounts_path)
    end

    it 'should persist token in applicant' do
      subject
      expect(applicant.reload.true_layer_token).to eq(token)
    end

    it 'should persist expires at in applicant' do
      subject
      expect(applicant.reload.true_layer_token_expires_at).to eq(expires_at)
    end

    context 'with a string time' do
      let(:true_layer_expires_at) { expires_at.to_json }
      it 'should persist expires at in applicant' do
        subject
        expect(applicant.reload.true_layer_token_expires_at).to eq(expires_at)
      end
    end

    context 'with nil time' do
      let(:true_layer_expires_at) { nil }
      it 'should persist expires at in applicant' do
        subject
        expect(applicant.reload.true_layer_token_expires_at).to be_nil
      end
    end

    context 'without applicant' do
      let(:applicant) { nil }

      it 'should redirect to root' do
        expect(subject).to redirect_to(citizens_consent_path)
      end
    end

    context 'on authentication failure' do
      before do
        OmniAuth.config.mock_auth[:true_layer] = :invalid_credentials
      end

      it 'should redirect to root' do
        # Faraday defined within OAuth2::Client outputs to console on error
        # which then outputs into the standard rspec progress sequence rather
        # than to logs. Mocking `logger.add` silences that output for this spec
        allow_any_instance_of(Logger).to receive(:add)
        subject
        follow_redirect!
        expect(request.env['REQUEST_URI']).to eq(citizens_consent_path)
      end
    end
  end
end
