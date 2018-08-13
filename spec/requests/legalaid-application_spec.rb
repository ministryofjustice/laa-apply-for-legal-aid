require 'rails_helper'

RSpec.describe 'Legal aid applications' do
  let(:response_json) {JSON.parse(response.body)}

  describe  'POST /api/v1/applications' do
    it 'returns an application reference' do

      post '/api/v1/applications'
      expect(response_json['data']['attributes']['application_ref']).to be
      expect(response.status).to eql(201)
    end
  end
end