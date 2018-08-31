require 'rails_helper'

RSpec.describe 'status requests' do
  let(:response_json) { JSON.parse(response.body) }

  describe 'GET /status' do
    it 'returns a status message' do
      get('/status')
      expect(response).to be_successful
      expect(response_json).to eq('status' => 'ok')
    end
  end
end
