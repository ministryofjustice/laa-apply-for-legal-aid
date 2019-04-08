require 'rails_helper'

RSpec.describe 'SamlSessionsController', type: :request do
  describe 'DELETE /providers/sign_out' do
    let(:provider) { create :provider }
    before { sign_in provider }
    subject { delete destroy_provider_session_path }

    it 'logs user out' do
      subject
      expect(controller.current_provider).to be_nil
    end

    it 'redirects to the SAML sign_out URL' do
      subject
      expect(response).to redirect_to(idp_sign_out_provider_session_url(SAMLRequest: 1))
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
end
