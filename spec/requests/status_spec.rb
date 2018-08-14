require 'rails_helper'


RSpec.describe 'status requests' do
  let(:response_json) {JSON.parse(response.body)}

  describe  'GET /v1/status' do
    it 'returns a status message' do
      get('/v1/status')
      expect(response_json['status']).to eql('ok')
      expect(response.status).to eql(200)
    end
  end
end