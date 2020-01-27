require 'rails_helper'

RSpec.describe 'Routes', type: :routing do
  describe 'GET /status' do
    it 'renders the correct route' do
      expect(get: '/status').to route_to('status#ping')
    end
  end
end
