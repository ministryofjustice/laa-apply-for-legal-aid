require 'rails_helper'

RSpec.describe 'citizen own home requests', type: :request do
  let(:application) { create :application, :with_applicant }
  let(:secure_id) { application.generate_secure_id }
  let(:provider) { legal_aid_application.provider }

  before do
    login_as provider
    subject
  end

  describe 'GET citizens/has_dependants' do
    it 'returns http success' do
      get citizens_has_dependants_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH citizens/has_dependants' do
    before { patch citizens_has_dependants_path, params: params }

    context 'valid params' do
      let(:params) { { legal_aid_application: { has_dependants: 'true' } } }

      it 'updates the record' do
        expect(application.reload.has_dependants).to be true
      end

      context 'yes' do
        it 'redirects to the add dependant details page' do
          expect(response).to redirect_to(citizens_dependants_path)
        end
      end

      context 'no' do
        let(:params) { { legal_aid_application: { has_dependants: 'false' } } }

        it 'redirects to the identify types of outgoing page' do
          expect(response).to redirect_to(citizens_identify_types_of_outgoing_path)
        end
      end
    end

    context 'invalid params - nothing specified' do
      let(:params) { {} }

      it 'returns http_success' do
        expect(response).to have_http_status(:ok)
      end

      it 'does not update the record' do
        expect(application.reload.has_dependants).to be_nil
      end

      it 'the response includes the error message' do
        expect(response.body).to include(I18n.t('activemodel.errors.models.legal_aid_application.attributes.has_dependants.blank'))
      end
    end
  end
end
