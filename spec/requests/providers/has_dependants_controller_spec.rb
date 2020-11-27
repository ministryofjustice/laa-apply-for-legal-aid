require 'rails_helper'

RSpec.describe Providers::HasDependantsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application }
  let(:login) { login_as legal_aid_application.provider }

  before do
    login
    subject
  end

  describe 'GET /providers/:application_id/has_dependants' do
    subject { get providers_legal_aid_application_has_dependants_path(legal_aid_application) }

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    context 'when the provider is not authenticated' do
      let(:login) { nil }

      it_behaves_like 'a provider not authenticated'
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/has_dependants' do
    let(:has_dependants) { nil }
    let(:params) do
      { legal_aid_application: { has_dependants: has_dependants } }
    end
    subject do
      patch(
        providers_legal_aid_application_has_dependants_path(legal_aid_application),
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

    describe 'PATCH /providers/:application_id/has_dependants' do
      before { patch providers_legal_aid_application_has_dependants_path(legal_aid_application), params: params }

      context 'valid params' do
        let(:params) { { legal_aid_application: { has_dependants: 'true' } } }

        it 'updates the record' do
          expect(legal_aid_application.reload.has_dependants).to be true
        end

        context 'yes' do
          it 'redirects to the add dependant details page' do
            expect(response).to redirect_to(new_providers_legal_aid_application_dependant_path(legal_aid_application))
          end
        end

        context 'no' do
          let(:params) { { legal_aid_application: { has_dependants: 'false' } } }

          it 'redirects to the outgoing summary page' do
            expect(response).to redirect_to(providers_legal_aid_application_no_outgoings_summary_path(legal_aid_application))
          end
        end
      end

      context 'while provider checking answers of citizen and no' do
        let(:legal_aid_application) do
          create :legal_aid_application, :with_applicant, :with_non_passported_state_machine,
                 :checking_non_passported_means
        end
        let(:params) { { legal_aid_application: { has_dependants: 'false' } } }

        it 'redirects to the means summary page' do
          expect(response).to redirect_to(providers_legal_aid_application_means_summary_path(legal_aid_application))
        end
      end

      context 'while provider checking answers of citizen and no dependants and yes' do
        let(:legal_aid_application) do
          create :legal_aid_application, :with_applicant, :with_non_passported_state_machine,
                 :checking_non_passported_means
        end
        let(:params) { { legal_aid_application: { has_dependants: 'true' } } }

        it 'redirects to the add dependant details page' do
          expect(response).to redirect_to(new_providers_legal_aid_application_dependant_path(legal_aid_application))
        end
      end

      context 'while provider checking answers of citizen and previously added dependants and yes' do
        let(:legal_aid_application) do
          create :legal_aid_application, :with_applicant, :with_non_passported_state_machine,
                 :checking_non_passported_means, :with_dependant
        end
        let(:params) { { legal_aid_application: { has_dependants: 'true' } } }

        it 'redirects to the has other dependants page' do
          expect(response).to redirect_to(providers_legal_aid_application_has_other_dependants_path(legal_aid_application))
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
end
