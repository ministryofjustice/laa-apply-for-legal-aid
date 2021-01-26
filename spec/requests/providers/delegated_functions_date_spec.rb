require 'rails_helper'
RSpec.describe Providers::DelegatedFunctionsDatesController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application }
  let(:login_provider) { login_as legal_aid_application.provider }

  before do
    login_provider
    subject
  end

  describe 'GET /providers/applications/:legal_aid_application_id/delegated_functions_date' do
    subject do
      get providers_legal_aid_application_delegated_functions_date_path(legal_aid_application)
    end

    it 'renders successfully' do
      expect(response).to have_http_status(:ok)
    end
  end
end
