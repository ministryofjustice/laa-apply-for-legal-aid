require 'rails_helper'

RSpec.describe Citizens::ContactProvidersController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :with_non_passported_state_machine, :applicant_entering_means }
  describe 'GET /citizens/contact_provider' do
    before do
      get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
      get citizens_contact_provider_path
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
      expect(unescaped_response_body).to include('Contact your solicitor')
    end
  end
end
