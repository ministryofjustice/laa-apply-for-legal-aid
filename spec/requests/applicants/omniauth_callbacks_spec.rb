require 'rails_helper'
require 'sidekiq/testing'

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
  let(:legal_aid_application) { create :legal_aid_application, :with_non_passported_state_machine, :awaiting_applicant, applicant: applicant }
  let(:bank_provider) { applicant.bank_providers.find_by(token: token) }

  before do
    get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id) if applicant
    OmniAuth.config.add_mock(
      :true_layer,
      credentials: {
        token: token,
        expires_at: true_layer_expires_at
      }
    )

    stub_true_layer
    ImportBankDataWorker.clear
  end

  describe 'GET /applicants/auth/true_layer/callback' do
    subject do
      get applicant_true_layer_omniauth_callback_path
      ImportBankDataWorker.drain
    end

    it 'redirects to next page' do
      expect(subject).to redirect_to(citizens_gather_transactions_path)
    end

    it 'persists the token on the applicant' do
      subject
      expect(applicant.reload.true_layer_token).to eq(token)
    end

    it 'does not add its url to page history' do
      subject
      expect(session.keys).not_to include(:page_history)
    end

    context 'with a string time' do
      let(:true_layer_expires_at) { expires_at.to_json }

      it 'persists expires_at' do
        subject
        expect(applicant.reload.true_layer_token_expires_at.utc.to_s).to eq(expires_at.utc.to_s)
      end
    end

    context 'with nil time' do
      let(:true_layer_expires_at) { nil }

      it 'does not persist expires_at' do
        subject
        expect(applicant.reload.true_layer_token_expires_at).to be_nil
      end
    end

    context 'without applicant' do
      let(:applicant) { nil }

      it 'redirects to root' do
        expect(subject).to redirect_to(citizens_consent_path)
      end
    end

    context 'on authentication failure' do
      before do
        OmniAuth.config.mock_auth[:true_layer] = :invalid_credentials

        # Faraday defined within OAuth2::Client outputs to console on error
        # which then outputs into the standard rspec progress sequence rather
        # than to logs. Mocking `logger.add` silences that output for this spec
        allow_any_instance_of(Logger).to receive(:add)
      end

      it 'redirects to error page' do
        subject
        follow_redirect!
        expect(response).to redirect_to(error_path(:access_denied))
      end

      it 'has reset the session and has no page history' do
        subject
        expect(session.keys).not_to include(:page_history)
      end
    end
  end
end
