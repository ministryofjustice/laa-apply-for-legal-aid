require 'rails_helper'

RSpec.describe Providers::RemoveDependantsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application }
  let(:dependant) { create :dependant, legal_aid_application: legal_aid_application }
  let(:login) { login_as legal_aid_application.provider }

  before do
    login
    subject
  end

  describe 'GET /providers/:application_id/remove_dependants/:dependant_id' do
    subject { get providers_legal_aid_application_remove_dependant_path(legal_aid_application, dependant) }

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    context 'when the provider is not authenticated' do
      let(:login) { nil }

      it_behaves_like 'a provider not authenticated'
    end
  end

  describe 'PATCH /providers/:application_id/remove_dependants/:dependant_id' do
    let(:params) do
      {
        binary_choice_form: {
          remove_dependant: remove_dependant
        }
      }
    end

    subject { patch providers_legal_aid_application_remove_dependant_path(legal_aid_application, dependant), params: params }

    context 'choose yes' do
      let(:remove_dependant) { 'true' }

      it 'redirects to the has other dependants page' do
        expect(response).to redirect_to(providers_legal_aid_application_has_other_dependants_path(legal_aid_application))
      end
    end

    context 'choose no' do
      let(:remove_dependant) { 'false' }

      it 'redirects to the has other dependants page' do
        expect(response).to redirect_to(providers_legal_aid_application_has_other_dependants_path(legal_aid_application))
      end
    end

    context 'try a hack to submit something else' do
      let(:remove_dependant) { 'not sure' }

      it 'show errors' do
        expect(response.body).to include(I18n.t('providers.remove_dependants.show.error'))
      end
    end

    context 'choose nothing' do
      let(:params) { nil }

      it 'show errors' do
        expect(response.body).to include(I18n.t('providers.remove_dependants.show.error'))
      end
    end
  end
end
