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
        expect(unescaped_response_body).to include('Check if you can continue using this service')
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
    let(:uses_online_banking) { 'true' }
    let(:received_consent) { 'true' }
    let(:none_selected) { nil }
    let(:submit_button) { {} }
    let(:params) do
      {
        legal_aid_application: {
          citizen_uses_online_banking: uses_online_banking,
          provider_received_citizen_consent: received_consent,
          none_selected: none_selected
        }
      }
    end

    subject do
      patch(
        "/providers/applications/#{application_id}/does-client-use-online-banking",
        params: params.merge(submit_button)
      )
    end

    context 'when the provider is authenticated' do
      before do
        login_as provider
        subject
      end

      context 'when no option is chosen' do
        let(:uses_online_banking) { nil }
        let(:received_consent) { nil }

        it 'shows an error' do
          expect(unescaped_response_body).to include('Please select an option')
        end
      end

      context 'uses online banking and consent provided' do
        let(:uses_online_banking) { 'true' }
        let(:received_consent) { 'true' }

        it 'updates the application' do
          expect(application.reload.citizen_uses_online_banking).to eq(true)
          expect(application.reload.provider_received_citizen_consent).to eq(true)
        end

        it 'redirects to check_provider_answers page' do
          expect(response).to redirect_to(providers_legal_aid_application_email_address_path(application))
        end
      end

      context 'uses online banking for all accounts and consent not provided' do
        let(:uses_online_banking) { 'true' }
        let(:received_consent) { '' }

        it 'updates the application' do
          expect(application.reload.citizen_uses_online_banking).to eq(true)
          expect(application.reload.provider_received_citizen_consent).to eq(false)
        end
        it 'redirects to use_ccms page' do
          expect(response).to redirect_to(providers_legal_aid_application_use_ccms_path(application))
        end
      end

      context 'does not use online banking for all accounts but consent provided' do
        let(:uses_online_banking) { '' }
        let(:received_consent) { 'true' }

        it 'updates the application' do
          expect(application.reload.citizen_uses_online_banking).to eq(false)
          expect(application.reload.provider_received_citizen_consent).to eq(true)
        end

        it 'redirects to use_ccms page' do
          expect(response).to redirect_to(providers_legal_aid_application_use_ccms_path(application))
        end
      end

      context 'checks none selected option' do
        let(:uses_online_banking) { '' }
        let(:received_consent) { '' }
        let(:none_selected) { 'true' }

        it 'updates the application' do
          expect(application.reload.citizen_uses_online_banking).to eq(false)
          expect(application.reload.provider_received_citizen_consent).to eq(false)
        end

        it 'redirects to use ccms page' do
          expect(response).to redirect_to(providers_legal_aid_application_use_ccms_path(application))
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
