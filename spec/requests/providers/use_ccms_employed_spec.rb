require 'rails_helper'

RSpec.describe Providers::UseCCMSEmployedController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application }
  let(:provider) { legal_aid_application.provider }

  describe 'GET /providers/applications/:id/use_ccms_employed' do
    subject { get providers_legal_aid_application_use_ccms_employed_index_path(legal_aid_application) }

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
        expect(response.body).to include(I18n.t('providers.use_ccms_employed.index.title_html'))
      end

      it 'sets state to use_ccms and reason to employed' do
        expect(legal_aid_application.reload.state).to eq 'use_ccms'
        expect(legal_aid_application.ccms_reason).to eq 'employed'
      end
    end
  end
end
