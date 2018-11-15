require 'rails_helper'

RSpec.describe 'provider start of journey test', type: :request do
  describe 'GET /providers' do
    let(:perform_request) { get providers_root_path }

    it_behaves_like 'a provider not authenticated'

    context 'when the provider is authenticated' do
      let(:provider) { create(:provider) }

      before do
        login_as provider
      end

      it 'returns http success' do
        perform_request
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
