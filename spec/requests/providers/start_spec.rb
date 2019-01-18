require 'rails_helper'

RSpec.describe 'provider start of journey test', type: :request do
  describe 'GET /providers' do
    subject { get providers_root_path }

    before do
      subject
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end
  end
end
