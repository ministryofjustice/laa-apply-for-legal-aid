require 'rails_helper'

RSpec.describe 'status requests' do
  describe 'GET /' do
    it 'returns renders successfully' do
      get root_path
      expect(response).to have_http_status(:ok)
    end
  end
end
