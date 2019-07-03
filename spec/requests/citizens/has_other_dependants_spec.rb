require 'rails_helper'

RSpec.describe Citizens::HasOtherDependantsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_applicant }

  before do
    get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
    subject
  end

  describe 'GET /citizens/has_other_dependant' do
    subject { get citizens_has_other_dependant_path }

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /citizens/has_other_dependant' do
    let(:params) do
      {
        other_dependant: other_dependant
      }
    end

    subject { patch citizens_has_other_dependant_path, params: params }

    context 'choose yes' do
      let(:other_dependant) { 'yes' }

      it 'redirects to the page to add another dependant' do
        expect(response).to redirect_to(citizens_dependants_path)
      end
    end

    context 'choose no' do
      let(:other_dependant) { 'no' }

      it 'redirects to the types of outgoings page' do
        expect(response).to redirect_to(citizens_identify_types_of_outgoing_path)
      end
    end

    context 'choose something else' do
      let(:other_dependant) { 'not sure' }

      it 'show errors' do
        expect(response.body).to include(I18n.t('citizens.has_other_dependants.show.error'))
      end
    end

    context 'choose nothing' do
      let(:params) {}

      it 'show errors' do
        expect(response.body).to include(I18n.t('citizens.has_other_dependants.show.error'))
      end
    end
  end
end
