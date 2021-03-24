require 'rails_helper'

RSpec.describe Providers::ReceivedBenefitConfirmationsController, type: :request do
  let(:application) { create(:legal_aid_application, :with_proceeding_types, :at_checking_applicant_details, :with_applicant_and_address) }
  let(:application_id) { application.id }

  describe 'GET /providers/applications/:legal_aid_application_id/received_benefit_confirmation' do
    subject { get "/providers/applications/#{application_id}/received_benefit_confirmation" }

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      before do
        login_as application.provider
        subject
      end

      it 'returns success' do
        expect(response).to be_successful
      end

      it 'displays the correct page' do
        expect(unescaped_response_body).to include('Which passporting benefit does your client receive?')
      end
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/received_benefit_confirmation' do
    subject { patch "/providers/applications/#{application_id}/received_benefit_confirmation", params: params }
    let(:params) { { dwp_override: { passporting_benefit: nil } } }

    before do
      login_as application.provider
    end

    context 'validation error' do
      it 'displays error if nothing selected' do
        subject
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Select if your client has received any of these benefits')
      end
    end

    context 'benefit selected' do
      let(:params) { { dwp_override: { passporting_benefit: :universal_credit } } }

      context 'add new record' do
        it 'adds a dwp override record' do
          expect { subject }.to change { DWPOverride.count }.by(1)
        end

        it 'updates the same dwp override record' do
          subject
          expect { subject }.not_to change { DWPOverride.count }
        end
      end

      context 'remove record when changed to none selected' do
        before do
          params = { dwp_override: { passporting_benefit: :universal_credit } }
          patch "/providers/applications/#{application_id}/received_benefit_confirmation", params: params
        end

        let(:params) { { dwp_override: { passporting_benefit: :none_selected } } }

        it 'removes the record' do
          expect { subject }.to change { DWPOverride.count }.by(-1)
        end
      end

      it 'continue to the has_evidence_of_benefit page' do
        subject
        expect(response).to redirect_to(providers_legal_aid_application_has_evidence_of_benefit_path(application))
      end
    end

    context 'none of these selected' do
      let(:params) { { dwp_override: { passporting_benefit: :none_selected } } }

      it 'does not add a dwp override record' do
        expect { subject }.not_to change { DWPOverride.count }
      end

      it 'continue to the applicant details page' do
        subject
        expect(response).to redirect_to(providers_legal_aid_application_applicant_employed_index_path(application))
      end

      it 'transitions the application state to applicant details checked' do
        subject
        expect(application.reload.state).to eq 'applicant_details_checked'
      end
    end
  end
end
