require 'rails_helper'

RSpec.describe 'citizen accounts request test', type: :request do
  describe 'GET /citizens/account' do
    let(:applicant) { create :applicant }

    before do
      sign_in applicant
      get citizens_accounts_path
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end
  end
end
