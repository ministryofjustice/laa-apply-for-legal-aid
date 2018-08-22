require 'rails_helper'

RSpec.describe 'status requests' do
  let(:response_json) { JSON.parse(response.body) }

  describe 'GET /status' do
    it 'returns a status message' do
      get('/status')
      expect(response).to be_successful
      expected_response_body = {
        'status' => 'ok',
        'healthcheck' => {
          'database' => true
        }
      }
      expect(response_json).to eq(expected_response_body)
    end
  end
end
