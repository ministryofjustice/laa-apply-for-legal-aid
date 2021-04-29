require 'rails_helper'

RSpec.describe 'does client use online banking requests', type: :request do
  let(:application) { create :legal_aid_application, :with_non_passported_state_machine, :applicant_details_checked }
  let(:application_id) { application.id }
  let(:provider) { application.provider }

  describe 'GET /providers/applications/:legal_aid_application_id/applicant' do
    subject { get "/providers/applications/#{application_id}/does-client-use-online-banking" }

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

      it 'displays the correct page' do
        expect(unescaped_response_body).to include(I18n.t('providers.open_banking_consents.show.heading'))
      end

      context 'the application is in use_ccms state' do
        let(:application) { create :legal_aid_application, :with_non_passported_state_machine, :use_ccms }
        it 'resets the state to provider_confirming_applicant_eligibility' do
          expect(application.reload.state).to eq 'provider_confirming_applicant_eligibility'
        end
      end
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/does-client-use-online-banking' do
    let(:provider_received_citizen_consent) { 'true' }
    let(:submit_button) { {} }
    let(:params) do
      {
        legal_aid_application: {
          provider_received_citizen_consent: provider_received_citizen_consent
        }
      }
    end

    subject do
      patch(
        "/providers/applications/#{application_id}/does-client-use-online-banking",
        params: params.merge(submit_button)
      )
    end

    context 'the provider is authenticated' do
      before do
        login_as provider
        subject
      end

      it 'updates the application' do
        expect(application.reload.provider_received_citizen_consent).to eq(true)
      end

      context 'applicant is not employed after negative benefit check result' do
        context 'used_delegated_functions is true' do
          let(:application) do
            create :legal_aid_application,
                   :with_non_passported_state_machine,
                   :applicant_details_checked,
                   :with_proceeding_types,
                   :with_delegated_functions, applicant: applicant
          end

          let(:applicant) { create :applicant, :not_employed }

          it 'redirects to the substantive application page' do
            expect(response).to redirect_to(providers_legal_aid_application_substantive_application_path(application))
          end
        end

        context 'used_delegated_functions is false' do
          let(:application) do
            create :legal_aid_application, :with_non_passported_state_machine, :applicant_details_checked, applicant: applicant
          end

          let(:applicant) { create :applicant, :not_employed }

          it 'redirects to the client instructions page' do
            expect(response).to redirect_to(providers_legal_aid_application_non_passported_client_instructions_path(application))
          end
        end
      end

      context 'positive benefit check result' do
        it 'redirects to the client instructions page' do
          expect(response).to redirect_to(providers_legal_aid_application_non_passported_client_instructions_path(application))
        end

        context 'provider_received_citizen_consent is false' do
          let(:provider_received_citizen_consent) { 'false' }
          it 'redirects to the use ccms page' do
            expect(response).to redirect_to(providers_legal_aid_application_use_ccms_path(application))
          end
        end
      end

      context 'no option is chosen' do
        let(:params) { {} }

        it 'shows an error' do
          expect(unescaped_response_body).to include(I18n.t('activemodel.errors.models.legal_aid_application.attributes.open_banking_consents.providers.blank'))
        end
      end

      context 'Form submitted using Save as draft button' do
        let(:submit_button) { { draft_button: 'Save as draft' } }

        it "redirects provider to provider's applications page" do
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end

        it 'sets the application as draft' do
          expect(application.reload).to be_draft
        end

        context 'when no option is chosen' do
          let(:params) { {} }

          it "redirects provider to provider's applications page" do
            expect(response).to redirect_to(providers_legal_aid_applications_path)
          end
        end
      end
    end
  end
end
