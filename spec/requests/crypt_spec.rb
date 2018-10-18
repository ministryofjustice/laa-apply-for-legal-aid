require 'rails_helper'

RSpec.describe 'status requests' do
  describe 'POST /vi/crypt' do
    let(:application) { create :application }
    let(:crypt) { Crypt.new }
    let(:token) { crypt.encrypt(application.application_ref) }
    let(:json) { JSON.parse(response.body, symbolize_names: true) }

    before do
      post '/v1/crypt', params: { token: token }
    end

    it 'responds successfully' do
      expect(response).to have_http_status(:ok)
    end

    it 'return application ref' do
      expect(json[:text]).to eq(application.application_ref)
    end
  end
end
