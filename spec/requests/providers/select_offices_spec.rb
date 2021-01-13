require 'rails_helper'

RSpec.describe 'provider selects office', type: :request do
  let(:firm) { create :firm }
  let!(:office1) { create :office, firm: firm }
  let!(:office2) { create :office, firm: firm }
  let!(:office3) { create :office, firm: firm }

  let(:provider) { create :provider, firm: firm, offices: [office1, office2] }

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

      it 'displays the offices of the provider' do
        expect(unescaped_response_body).to include(office1.code)
        expect(unescaped_response_body).to include(office2.code)
      end

      it 'does not display offices belonging to the firm but not the provider' do
        expect(unescaped_response_body).not_to include(office3.code)
      end
    end
  end

  describe 'PATCH providers/select_office' do
    subject { patch providers_select_office_path, params: params }

    let(:params) do
      {
        provider: { selected_office_id: office2.id }
      }
    end

    context 'when the provider is authenticated' do
      before do
        login_as provider
        subject
      end

      it 'updates the record' do
        expect(provider.reload.selected_office.id).to eq office2.id
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
          expect(response.body).to include(I18n.t('activemodel.errors.models.provider.attributes.selected_office_id.blank'))
        end
      end

      context 'invalid params - selects office from different provider' do
        let(:params) do
          {
            provider: { selected_office_id: office3.id }
          }
        end

        it 'returns http_success' do
          expect(response).to have_http_status(:ok)
        end

        it 'the response includes the error message' do
          expect(response.body).to include(I18n.t('activemodel.errors.models.provider.attributes.selected_office_id.blank'))
        end
      end
    end
  end
end
