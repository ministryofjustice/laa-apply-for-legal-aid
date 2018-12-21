require 'rails_helper'

RSpec.describe 'provider own home requests', type: :request do
  let(:legal_aid_application) { create :legal_aid_application }

  describe 'GET providers/own_home' do
    before { get providers_legal_aid_application_own_home_path(legal_aid_application) }
    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH providers/own_home' do
    let(:own_home) { 'owned_outright' }
    let(:params) do
      {
        legal_aid_application: { own_home: own_home },
        'continue-button' => 'Continue'
      }
    end

    context 'Continue button pressed' do
      before { patch providers_legal_aid_application_own_home_path(legal_aid_application), params: params }

      it 'updates the record' do
        expect(legal_aid_application.reload.own_home).to eq own_home
      end

      context 'owned outright' do
        it 'redirects to the property value page' do
          expect(response).to redirect_to providers_legal_aid_application_property_value_path(legal_aid_application)
        end

        it 'updates the record to match' do
          expect(legal_aid_application.reload.own_home_owned_outright?).to be_truthy
        end
      end

      context 'mortgaged' do
        let(:own_home) { 'mortgage' }

        it 'redirects to the property value page' do
          expect(response).to redirect_to providers_legal_aid_application_property_value_path(legal_aid_application)
        end

        it 'updates the record to match' do
          expect(legal_aid_application.reload.own_home_mortgage?).to be_truthy
        end
      end
    end

    context 'Save as draft button pressed' do
      before do
        params.delete('continue-button')
        params['draft-button'] = 'Save as draft'
        patch providers_legal_aid_application_own_home_path(legal_aid_application), params: params
      end

      it 'updates the record' do
        expect(legal_aid_application.reload.own_home).to eq own_home
      end

      context 'owned outright' do
        it 'redirects to provider applications home page' do
          expect(response).to redirect_to providers_legal_aid_applications_path
        end

        it 'updates the record to match' do
          expect(legal_aid_application.reload.own_home_owned_outright?).to be_truthy
        end
      end

      context 'mortgaged' do
        let(:own_home) { 'mortgage' }

        it 'redirects to 1b. How much is your client’s home worth' do
          expect(response).to redirect_to providers_legal_aid_applications_path
        end

        it 'updates the record to match' do
          expect(legal_aid_application.reload.own_home_mortgage?).to be_truthy
        end
      end

      context 'no' do
        let(:own_home) { 'no' }

        it 'redirects to savings or investments question' do
          expect(response).to redirect_to providers_legal_aid_applications_path
        end

        it 'updates the record to match' do
          expect(legal_aid_application.reload.own_home_no?).to be_truthy
        end
      end

      context 'invalid params - nothing specified' do
        let(:params) { {} }

        it 'returns http_success' do
          expect(response).to have_http_status(:ok)
        end

        it 'does not update the record' do
          expect(legal_aid_application.reload.own_home).to be_nil
        end

        it 'the response includes the error message' do
          expect(response.body).to include(I18n.t('activemodel.errors.models.legal_aid_application.attributes.own_home.blank'))
        end
      end
    end
  end
end
