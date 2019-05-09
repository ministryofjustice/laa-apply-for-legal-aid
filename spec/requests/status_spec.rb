require 'rails_helper'

RSpec.describe 'status requests' do
  let(:response_json) { JSON.parse(response.body) }
  let(:expected_json) do
    {
      'redis' => true,
      'db' => true,
      'malware_scanner' => {
        'positive' => true,
        'negative' => true
      }
    }
  end

  describe 'GET /status' do
    subject { get('/status') }
    before { subject }

    it 'is successful' do
      expect(response).to be_successful
    end

    it 'checks external connections' do
      expect(response_json).to eq(expected_json)
    end
  end
end
