require 'rails_helper'

RSpec.describe Providers::DeleteController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_everything, substantive_application_deadline_on: 1.days.ago }
  let(:provider) { legal_aid_application.provider }

  describe 'GET /providers/applications/:id/delete' do
    subject { get providers_legal_aid_application_delete_path(legal_aid_application) }

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
        expect(unescaped_response_body).to include('Are you sure you want to delete this application?')
      end

      it 'displays the application data' do
        expect(unescaped_response_body).to include("LAA reference: <strong>#{legal_aid_application.application_ref}</strong>")
      end
    end
  end

  describe 'DELETE /admin/legal_aid_applications/:legal_aid_application_id/destroy' do
    subject { delete providers_legal_aid_application_delete_path(legal_aid_application) }

    before do
      login_as provider
      subject
    end

    it 'sets the application to discarded' do
      expect(legal_aid_application.reload.discarded_at).not_to be nil
    end

    it 'returns http found' do
      expect(response).to have_http_status(:found)
    end
  end
end
