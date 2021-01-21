require 'rails_helper'

RSpec.describe Providers::DelegatedConfirmationController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_everything, substantive_application_deadline_on: 1.day.ago }
  let(:provider) { legal_aid_application.provider }

  describe 'GET /providers/applications/:id/delegated_confirmation' do
    subject { get providers_legal_aid_application_delegated_confirmation_index_path(legal_aid_application) }

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
        expect(unescaped_response_body).to include("You told us you've used delegated functions")
      end

      it 'displays the deadline date' do
        expect(unescaped_response_body).to include("You must submit a substantive application by #{legal_aid_application.substantive_application_deadline_on}.")
      end
    end
  end
end
