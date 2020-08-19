require 'rails_helper'

RSpec.describe Providers::UseCcmsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application }
  let(:provider) { legal_aid_application.provider }

  describe 'GET /providers/applications/:id/use_ccms' do
    subject { get providers_legal_aid_application_use_ccms_path(legal_aid_application) }

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

      it 'shows text to use CCMS' do
        subject
        expect(response.body).to include(I18n.t('providers.use_ccms.show.title_html'))
      end
    end
  end
end
