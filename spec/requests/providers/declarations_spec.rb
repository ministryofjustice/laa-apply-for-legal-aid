require 'rails_helper'

RSpec.describe Providers::DeclarationsController, type: :request do
  let(:provider) { create :provider }
  subject(:visit_page) { get(providers_declaration_path) }

  describe 'GET /providers/declaration' do
    before do
      login_as provider
      visit_page
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'displays the correct page' do
      expect(unescaped_response_body).to include('Declaration')
    end
  end
end
