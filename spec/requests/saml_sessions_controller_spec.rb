require 'rails_helper'

RSpec.describe 'SamlSessionsController' do
  describe 'DELETE /providers/sign_out' do
    let(:provider) { create :provider }
    before { sign_in provider }
    subject { delete destroy_provider_session_path }

    it 'logs user out' do
      subject
      expect(controller.current_provider).to be_nil
    end

    it 'redirects to providers root' do
      subject
      expect(response).to redirect_to(providers_root_url)
    end
  end
end
