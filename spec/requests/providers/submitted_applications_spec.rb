require 'rails_helper'

RSpec.describe Providers::SubmittedApplicationsController, type: :request do
  let(:legal_aid_application) do
    create :legal_aid_application, :with_everything, :with_proceeding_types, state: :assessment_submitted
  end
  let(:login) { login_as legal_aid_application.provider }

  before do
    login
    subject
  end

  describe 'GET /providers/applications/:legal_aid_application_id/submitted_application' do
    subject do
      get providers_legal_aid_application_submitted_application_path(legal_aid_application)
    end

    it 'renders successfully' do
      expect(response).to have_http_status(:ok)
    end

    it 'displays reference' do
      expect(response.body).to include(legal_aid_application.application_ref)
    end

    context 'when the provider is not authenticated' do
      let(:login) { nil }

      it_behaves_like 'a provider not authenticated'
    end

    context 'with another provider' do
      let(:login) { login_as create(:provider) }

      it 'redirects to access denied error' do
        expect(response).to redirect_to(error_path(:access_denied))
      end
    end
  end
end
