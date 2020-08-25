require 'rails_helper'

RSpec.describe Providers::NonPassportedClientInstructionsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application }
  let(:provider) { legal_aid_application.provider }

  describe 'GET /providers/applications/:id/non_passported_client_instructions' do
    subject { get providers_legal_aid_application_non_passported_client_instructions_path(legal_aid_application) }

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      before do
        login_as provider
        subject
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'displays the correct page' do
        subject
        expect(response.body).to include('What your client has to do')
      end
    end
  end
end
