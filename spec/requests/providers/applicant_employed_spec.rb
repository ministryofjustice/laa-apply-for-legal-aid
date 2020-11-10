require 'rails_helper'

RSpec.describe Providers::ApplicantEmployedController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, applicant: applicant }
  let(:applicant) { create :applicant }
  let(:login) { login_as legal_aid_application.provider }

  before do
    login
    subject
  end

  describe 'GET /providers/:application_id/applicant_employed' do
    subject { get providers_legal_aid_application_applicant_employed_index_path(legal_aid_application) }

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    context 'when the provider is not authenticated' do
      let(:login) { nil }

      it_behaves_like 'a provider not authenticated'
    end

    context 'when the application is in use_ccms state' do
      let(:legal_aid_application) { create :legal_aid_application, :use_ccms_employed, applicant: applicant }
      it 'sets the state back to applicant details checked and removes the reason' do
        expect(legal_aid_application.reload.state).to eq 'applicant_details_checked'
        expect(legal_aid_application.ccms_reason).to be_nil
      end
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/applicant_employed' do
    let(:employed) { nil }
    let(:params) do
      { applicant: { employed: employed } }
    end

    subject do
      post(
        providers_legal_aid_application_applicant_employed_index_path(legal_aid_application),
        params: params
      )
    end

    it 'renders successfully' do
      expect(response).to have_http_status(:ok)
    end

    it 'displays error' do
      expect(response.body).to include('govuk-error-summary')
    end

    context 'when the provider is not authenticated' do
      let(:login) { nil }

      it_behaves_like 'a provider not authenticated'
    end

    describe 'POST /providers/:application_id/applicant_employed' do
      before { post providers_legal_aid_application_applicant_employed_index_path(legal_aid_application), params: params }

      context 'valid params' do
        let(:params) { { applicant: { employed: 'true' } } }

        it 'updates the record' do
          applicant = legal_aid_application.reload.applicant
          expect(applicant.reload.employed).to be true
        end

        context 'yes' do
          it 'redirects to the use ccms employed page' do
            expect(response).to redirect_to(providers_legal_aid_application_use_ccms_employed_index_path(legal_aid_application))
          end
        end

        context 'no' do
          let(:params) { { applicant: { employed: 'false' } } }

          it 'redirects to the open banking consents page' do
            expect(response).to redirect_to(providers_legal_aid_application_open_banking_consents_path(legal_aid_application))
          end
        end
      end

      context 'invalid params - nothing specified' do
        let(:params) { {} }

        it 'returns http_success' do
          expect(response).to have_http_status(:ok)
        end

        it 'does not update the record' do
          applicant = legal_aid_application.reload.applicant
          expect(applicant.reload.employed).to be_nil
        end

        it 'includes the error message in the response' do
          expect(response.body).to include(I18n.t('activemodel.errors.models.applicant.attributes.employed.blank'))
        end
      end
    end
  end
end
