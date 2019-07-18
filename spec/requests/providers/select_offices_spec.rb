require 'rails_helper'

RSpec.describe 'provider selects office', type: :request do
  let(:provider) { create :provider, firm: firm }
  let(:firm) { create :firm }

  describe 'GET providers/select_office' do
    subject { get providers_select_office_path }

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

      it 'displays the correct office name' do
        expect(unescaped_response_body).to include(firm.name)
      end
    end
  end

  describe 'PATCH providers/select_office' do
    subject { patch providers_select_office_path, params: params }
    let(:office1) { create :office, firm: firm }
    let!(:office2) { create :office, firm: firm }

    let(:params) do
      {
        provider: { office_id: office1.id }
      }
    end

    context 'when the provider is authenticated' do
      before do
        login_as provider
        subject
      end

      it 'updates the record' do
        expect(provider.reload.office.id).to eq office1.id
      end

      it 'redirects to the legal aid applications page' do
        expect(response).to redirect_to providers_legal_aid_applications_path
      end

      context 'invalid params - nothing specified' do
        let(:params) { {} }

        it 'returns http_success' do
          expect(response).to have_http_status(:ok)
        end

        it 'the response includes the error message' do
          expect(response.body).to include(I18n.t('activemodel.errors.models.provider.attributes.office_id.blank'))
        end
      end

      context 'invalid params - selects office from different firm' do
        let(:office3) { create :office }
        let(:params) do
          {
            provider: { office_id: office3.id }
          }
        end

        it 'returns http_success' do
          expect(response).to have_http_status(:ok)
        end

        it 'the response includes the error message' do
          expect(response.body).to include(I18n.t('activemodel.errors.models.provider.attributes.office_id.blank'))
        end
      end
    end
  end
end
