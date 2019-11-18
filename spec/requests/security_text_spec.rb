require 'rails_helper'

RSpec.describe 'security text page', type: :request do
  describe 'GET /.well-known/security.txt' do
    it 'redirects successfully' do
      get '/.well-known/security.txt'
      expect(response).to redirect_to('https://raw.githubusercontent.com/ministryofjustice/security-guidance/master/contact/vulnerability-disclosure-security.txt')
    end
  end
end
