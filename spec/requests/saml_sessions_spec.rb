require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe 'SamlSessionsController', type: :request do
  let(:firm) { nil }
  let(:office) { nil }
  let(:provider) { create :provider, firm: firm, selected_office: office }

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
        expect(response).to redirect_to(idp_sign_out_provider_session_url(SAMLRequest: 1))
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
    let(:sample_provider_details) { { foo: 'bar' } }

    subject { post provider_session_path }

    before do
      allow_any_instance_of(Warden::Proxy).to receive(:authenticate!).and_return(provider)
    end

    it 'retrieves provider details' do
      expect(ProviderDetailsCreator).to receive(:call).with(provider).and_call_original
      subject
      expect(provider.firm).to_not be_nil
    end

    it 'does not use a worker' do
      expect(ProviderDetailsCreatorWorker).not_to receive(:perform_async)
      subject
    end

    it 'redirects to the confirm office page' do
      subject
      expect(response).to redirect_to(providers_confirm_office_path)
    end

    context 'provider already has some provider details' do
      let(:firm) { create :firm }

      it 'uses a worker' do
        ProviderDetailsCreatorWorker.clear
        expect(ProviderDetailsCreatorWorker).to receive(:perform_async).with(provider.id).and_call_original
        expect(ProviderDetailsCreator).to receive(:call).with(provider).and_call_original
        subject
        ProviderDetailsCreatorWorker.drain
      end
    end
  end
end
