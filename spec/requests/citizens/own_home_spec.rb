require 'rails_helper'

RSpec.describe 'citizen own home requests', type: :request do
  let(:application) { create :application, :with_applicant }
  let(:application_id) { application.id }
  let(:secure_id) { application.generate_secure_id }

  before { get citizens_legal_aid_application_path(secure_id) }

  describe 'GET citizens/own_home' do
    it 'returns http success' do
      get citizens_own_home_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH citizens/own_home' do
    before { patch citizens_own_home_path, params: params }

    context 'valid params' do
      let(:params) { { 'legal_aid_application' => { 'own_home' => 'owned_outright' } } }

      it 'returns http_success' do
        expect(response).to have_http_status(:found)
      end

      it 'updates the record' do
        expect(application.reload.own_home).to eq 'owned_outright'
      end

      context 'owned outright' do
        it 'redirects to the property value page' do
          expect(response).to redirect_to(citizens_property_value_path)
        end
      end

      context 'mortgaged' do
        let(:params) { { 'legal_aid_application' => { 'own_home' => 'mortgage' } } }

        it 'redirects to the property value page' do
          expect(response).to redirect_to(citizens_property_value_path)
        end
      end

      context 'no' do
        let(:params) { { 'legal_aid_application' => { 'own_home' => 'no' } } }
        # TODO: setup redirect when known
        xit 'redirects to the value of your home page' do
          expect(response).to redirect_to(:savings_or_investments_path)
        end

        # TODO: remove when redirect set up
        it 'displays holding text' do
          expect(response.body).to eq 'Navigate to question 2a; Do you have any savings or investments'
        end
      end
    end

    context 'invalid params - nothing specified' do
      let(:params) { {} }

      it 'returns http_success' do
        expect(response).to have_http_status(:ok)
      end

      it 'does not update the record' do
        expect(application.reload.own_home).to be_nil
      end

      it 'the response includes the error message' do
        expect(response.body).to include(I18n.t('activemodel.errors.models.legal_aid_application.attributes.own_home.blank'))
      end
    end
  end
end
