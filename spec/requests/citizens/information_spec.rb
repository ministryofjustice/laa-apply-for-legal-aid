require 'rails_helper'

RSpec.describe 'citizen information request test', type: :request do
  describe 'GET /citizens/information' do
    let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :with_non_passported_state_machine, :applicant_entering_means }
    before do
      get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
      get citizens_information_path
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end
  end
end
