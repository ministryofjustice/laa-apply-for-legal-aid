require 'rails_helper'

RSpec.describe 'provider confirm office', type: :request do
  let(:firm) { create :firm }
  let!(:office) { create :office, firm: firm }
  let!(:office2) { create :office, firm: firm }
  let(:provider) { create :provider, firm: firm, selected_office: office }

  describe 'GET providers/confirm_office' do
    subject { get providers_confirm_office_path }

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'invalid login' do
      let(:provider) { create :provider, invalid_login_details: 'role' }

      before do
        login_as provider
        subject
      end

      it 'redirects to the invalid login page' do
        expect(response).to redirect_to providers_invalid_login_path
      end
    end

    context 'when the provider is authenticated' do
      before do
        login_as provider
        subject
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it 'displays the correct office legal aid code' do
        expect(unescaped_response_body).to include(office.code)
      end

      it 'sets the page_history_id' do
        expect(session['page_history_id']).not_to be_nil
      end

      context 'firm has only one office' do
        let!(:office) { nil }

        it 'assigns office 2 to the provider' do
          expect(provider.reload.selected_office).to eq office2
        end

        it 'redirects to the legal aid applications page' do
          expect(response).to redirect_to providers_legal_aid_applications_path
        end
      end

      context 'provider has not selected office' do
        let(:provider) { create :provider, firm: firm, selected_office: nil }

        it 'redirects to the select office page' do
          expect(response).to redirect_to providers_select_office_path
        end
      end
    end
  end

  describe 'PATCH providers/confirm_office' do
    subject { patch providers_confirm_office_path, params: params }
    let(:params) { { binary_choice_form: { confirm_office: 'true' } } }

    context 'when the provider is authenticated' do
      before do
        login_as provider
        subject
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
          expect(response.body).to include(I18n.t('providers.confirm_offices.show.error'))
        end
      end

      context 'no is selected' do
        let(:params) { { binary_choice_form: { confirm_office: 'false' } } }

        it 'redirects to the office select page' do
          expect(response).to redirect_to providers_select_office_path
        end

        it 'clears the existing office' do
          expect(provider.reload.selected_office).to eq nil
        end
      end
    end
  end
end
