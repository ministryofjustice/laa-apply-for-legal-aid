require 'rails_helper'

RSpec.describe Providers::HasDependantsController, type: :request do
  let(:legal_aid_application) { create :application, :with_applicant }
  let(:secure_id) { legal_aid_application.generate_secure_id }
  let(:provider) { legal_aid_application.provider }

  before do
    login_as provider
    subject
  end

  describe 'GET /providers/:application_id/has_dependants' do
    it 'returns http success' do
      get providers_legal_aid_application_has_dependants_path(legal_aid_application)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /providers/:application_id/has_dependants' do
    before { patch providers_legal_aid_application_has_dependants_path(legal_aid_application), params: params }

    context 'valid params' do
      let(:params) { { legal_aid_application: { has_dependants: 'true' } } }

      it 'updates the record' do
        expect(legal_aid_application.reload.has_dependants).to be true
      end

      context 'yes' do
        it 'redirects to the add dependant details page' do
          expect(response).to redirect_to(providers_legal_aid_application_dependants_path)
        end
      end

      context 'no' do
        let(:params) { { legal_aid_application: { has_dependants: 'false' } } }

        it 'redirects to the outgoing summary page' do
          expect(response).to redirect_to(providers_legal_aid_application_outgoings_summary_index_path(legal_aid_application))
        end
      end
    end

    context 'invalid params - nothing specified' do
      let(:params) { {} }

      it 'returns http_success' do
        expect(response).to have_http_status(:ok)
      end

      it 'does not update the record' do
        expect(legal_aid_application.reload.has_dependants).to be_nil
      end

      it 'the response includes the error message' do
        expect(response.body).to include(I18n.t('activemodel.errors.models.legal_aid_application.attributes.has_dependants.blank'))
      end
    end
  end
end
