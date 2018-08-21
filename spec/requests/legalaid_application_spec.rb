require 'rails_helper'

RSpec.describe 'Legal aid applications' do
  let(:response_json) { JSON.parse(response.body) }

  describe 'POST /v1/applications' do
    it 'returns an application reference' do
      post '/v1/applications'
      puts response_json
      expect(response_json['data']['attributes']['application_ref']).not_to be_empty
      expect(response.status).to eql(201)
    end
  end
end
