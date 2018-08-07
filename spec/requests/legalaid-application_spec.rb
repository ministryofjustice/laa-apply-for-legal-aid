require 'rails_helper'

RSpec.describe 'Legal aid applications' do
  let(:response_json) {JSON.parse(response.body)}

  describe  'POST /legalaidapplications' do
    it 'returns an application reference' do
      params = { }
      post '/legalaidapplications', params
      expect(response_json['application_ref']).to eql('1234')
      expect(response.status).to eql(200)
    end
  end
end