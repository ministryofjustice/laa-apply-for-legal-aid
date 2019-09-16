require 'rails_helper'

RSpec.describe 'does client use online banking requests', type: :request do
  let(:applicant) { create :applicant, uses_online_banking: nil }
  let(:application) { create :legal_aid_application, applicant: applicant }
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
        expect(unescaped_response_body).to include('Does your client use online banking?')
      end
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/does-client-use-online-banking' do
    let(:params) { { applicant: { uses_online_banking: uses_online_banking } } }
    let(:submit_button) { {} }

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
        let(:params) { {} }

        it 'shows an error' do
          expect(unescaped_response_body).to include('Please select an option')
        end
      end

      context 'when "Yes" is chosen' do
        let(:uses_online_banking) { 'true' }

        it 'updates the applicant' do
          expect(applicant.reload.uses_online_banking).to eq(true)
        end

        it 'redirects to check_provider_answers page' do
          expect(response).to redirect_to(providers_legal_aid_application_email_address_path(application))
        end
      end

      context 'when "No" is chosen' do
        let(:uses_online_banking) { 'false' }

        it 'updates the applicant' do
          expect(applicant.reload.uses_online_banking).to eq(false)
        end

        it 'tells provider to use CCMS' do
          expect(unescaped_response_body).to include('use CCMS')
        end
      end

      context 'Form submitted using Save as draft button' do
        let(:submit_button) { { draft_button: 'Save as draft' } }
        let(:uses_online_banking) { 'true' }

        it "redirects provider to provider's applications page" do
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end

        it 'sets the application as draft' do
          expect(application.reload).to be_draft
        end

        context 'when no option is chosen' do
          let(:uses_online_banking) { '' }

          it "redirects provider to provider's applications page" do
            expect(response).to redirect_to(providers_legal_aid_applications_path)
          end
        end
      end
    end
  end
end
