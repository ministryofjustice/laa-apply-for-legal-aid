require 'rails_helper'
require Rails.root.join('app/lib/omni_auth/strategies/moj_oauth2')

module OmniAuth
  module Strategies
    RSpec.describe MojOauth2 do
      let(:mock_rack_app) { double Rack::Pjax, call: nil }
      let(:applicant_id) { '50b98c1b-cf5d-428e-b32c-d20e9d1184dd' }
      let(:omniauth_state) { '6ab2a928a9ac79ff38ad32f73c47db3fce9a0a8f5d069a76' }
      let(:strategy) { described_class.new(mock_rack_app, {}) }
      let(:session) { example_session }
      let(:client_id) { 'my_client_id' }
      let(:client_secret) { 'my_client_secret' }
      let(:client) { ::OAuth2::Client.new(client_id, client_secret, {}) }

      context 'request_phase' do
        before do
          allow(strategy).to receive(:session).and_return(example_session)
          allow(strategy).to receive(:authorize_params).and_return(example_auth_params)
          allow(strategy).to receive(:callback_url).and_return('http://dummy_callback')
          allow(strategy).to receive(:browser_details).and_return('Dummy browser details')
        end

        it 'saves the session with the applicant_id and omniauth state' do
          expect(OauthSessionSaver).to receive(:store).with(applicant_id, session)
          expect(OauthSessionSaver).to receive(:store).with(omniauth_state, session)
          strategy.request_phase
        end

        it 'writes a Debug record' do
          expect(Debug).to receive(:record_request).with(example_session,
                                                         example_auth_params,
                                                         'http://dummy_callback',
                                                         'Dummy browser details')
          strategy.request_phase
        end
      end

      context 'callback phase' do
        let(:mock_request) { double 'request', params: example_request_params, scheme: 'http', url: 'my_url' }
        let(:my_access_token) { OpenStruct.new(expired?: false) }

        before do
          allow(strategy).to receive(:request).and_return(mock_request)
          allow(strategy).to receive(:session).and_return(example_session)
          allow(strategy).to receive(:build_access_token).and_return(my_access_token)
          allow(strategy).to receive(:env).and_return(example_environment)
        end

        it 'restores session from redis' do
          expect(OauthSessionSaver).to receive(:get).with(omniauth_state).and_return(example_session)
          strategy.callback_phase
        end

        it 'destroys the stored session in redis' do
          expect(OauthSessionSaver).to receive(:destroy!).with(omniauth_state)
          strategy.callback_phase
        end
      end

      def example_session
        HashWithIndifferentAccess.new(
          {
            'session_id' => 'c38047b5f6a12c9de1540621ac8dc7d3',
            'current_application_id' => '583496de-f14e-46b5-bbff-8f95b4d6af22',
            'page_history_id' => 'c121c57a-2802-4793-b700-af30b212d63b',
            'warden.user.applicant.key' => [[applicant_id], nil],
            '_csrf_token' => 'bHisWZcUID4DqymnSBSyJ31OghMf8cop4Aw/9RJ3T9c=',
            'provider_id' => 'mock',
            'omniauth.state' => omniauth_state
          }
        )
      end

      def example_auth_params
        HashWithIndifferentAccess.new(
          {
            'state' => omniauth_state,
            'scope' => 'info accounts balance transactions',
            'enable_mock' => true,
            'provider_id' => 'mock',
            'consent_id' => 'applyforlegalaidtest-uxqw',
            'tracking_id' => '9829f7c1-e8c4-4334-8f39-ff48e024ea62'
          }
        )
      end

      def example_request_params
        HashWithIndifferentAccess.new(
          {
            state: omniauth_state
          }
        )
      end

      def example_environment
        HashWithIndifferentAccess.new(
          {
            'omniauth.auth' => {}
          }
        )
      end
    end
  end
end
