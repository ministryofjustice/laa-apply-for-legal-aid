require 'rails_helper'

RSpec.describe 'provider start of journey test', type: :request do
  describe 'GET /providers' do
    subject { get providers_root_path }

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      let(:provider) { create(:provider) }

      before do
        login_as provider
        subject
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
