require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe 'SamlSessionsController', type: :request do
  let(:firm) { create :firm, offices: [office] }
  let(:office) { create :office }
  let(:provider) { create :provider, firm: firm, selected_office: office, offices: [office], username: username }
  let(:username) { 'bob the builder' }
  let(:provider_details_api) { "#{Rails.configuration.x.provider_details.url}#{username.gsub(' ', '%20')}" }

  describe 'DELETE /providers/sign_out' do
    before { sign_in provider }
    subject { delete destroy_provider_session_path }

    it 'logs user out' do
      subject
      expect(controller.current_provider).to be_nil
    end

    context 'no mock saml' do
      before do
        allow(Rails.configuration.x.laa_portal).to receive(:mock_saml).and_return('false')
      end

      it 'redirects to the SAML sign_out URL' do
        subject
        expect(response).to redirect_to(new_feedback_path)
      end
    end

    context 'mock_saml' do
      before do
        allow(Rails.configuration.x.laa_portal).to receive(:mock_saml).and_return('true')
      end

      it 'redirects to providers root' do
        subject
        expect(response).to redirect_to(providers_root_url)
      end
    end
  end

  describe 'POST /providers/saml/auth' do
    subject { post provider_session_path }

    before do
      allow_any_instance_of(Warden::Proxy).to receive(:authenticate!).and_return(provider)
      stub_request(:get, provider_details_api).to_return(body: provider_details_response)
    end

    context 'provider already has some provider details' do
      let(:firm) { create :firm }

      context 'staging or production' do
        it 'uses a worker to update details' do
          expect(HostEnv).to receive(:staging_or_production?).and_return(true)
          ProviderDetailsCreatorWorker.clear
          expect(ProviderDetailsCreatorWorker).to receive(:perform_async).with(provider.id).and_call_original
          expect(ProviderDetailsCreator).to receive(:call).with(provider).and_call_original
          subject
          ProviderDetailsCreatorWorker.drain
        end
      end

      context 'test' do
        it 'does not schedule a worker to update details' do
          ProviderDetailsCreatorWorker.clear
          expect(ProviderDetailsCreatorWorker).not_to receive(:perform_async).with(provider.id).and_call_original
          expect(ProviderDetailsCreator).not_to receive(:call).with(provider).and_call_original
          subject
        end
      end
    end
  end

  def provider_details_response
    {
      providerFirmId: 22_381,
      contactUserId: 29_562,
      contacts: [
        {
          id: 568_352,
          name: 'SALLYCORNHILL'
        },
        {
          id: 2_017_809,
          name: username
        }
      ],
      providerOffices: [
        {
          id: 81_693,
          name: 'Test1 and Co'
        }
      ]
    }.to_json
  end
end
