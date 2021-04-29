require 'rails_helper'

RSpec.describe Providers::HasEvidenceOfBenefitsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_dwp_override, :checking_applicant_details, :with_proceeding_types, :with_delegated_functions }
  let(:login) { login_as legal_aid_application.provider }

  before do
    login
    subject
  end

  describe 'GET /providers/:application_id/has_evidence_of_benefit' do
    subject { get providers_legal_aid_application_has_evidence_of_benefit_path(legal_aid_application) }

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    context 'when the provider is not authenticated' do
      let(:login) { nil }

      it_behaves_like 'a provider not authenticated'
    end
  end

  describe 'PATCH /providers/:application_id/has_evidence_of_benefit' do
    let(:has_evidence_of_benefit) { 'true' }
    let(:params) do
      {
        dwp_override: {
          has_evidence_of_benefit: has_evidence_of_benefit
        }
      }
    end

    subject { patch providers_legal_aid_application_has_evidence_of_benefit_path(legal_aid_application), params: params }

    it 'updates the state' do
      expect(legal_aid_application.reload.state).to eq 'applicant_details_checked'
    end

    context 'application state is already applicant_details_checked' do
      let(:legal_aid_application) { create :legal_aid_application, :with_dwp_override, :applicant_details_checked }

      it 'does not update the state' do
        expect(legal_aid_application).not_to receive(:applicant_details_checked!)
      end
    end

    it 'updates the dwp_override model' do
      dwp_override = legal_aid_application.reload.dwp_override
      expect(dwp_override.has_evidence_of_benefit).to be true
    end

    it 'redirects to the upload substantive application page' do
      expect(response).to redirect_to(providers_legal_aid_application_substantive_application_path(legal_aid_application))
    end

    context 'does not use delegated functions' do
      let(:legal_aid_application) { create :legal_aid_application, :with_dwp_override, :applicant_details_checked }

      it 'redirects to the upload capital introductions page' do
        expect(response).to redirect_to(providers_legal_aid_application_capital_introduction_path(legal_aid_application))
      end
    end

    it 'updates the state machine type' do
      expect(legal_aid_application.reload.state_machine).to be_a_kind_of PassportedStateMachine
    end

    context 'choose no' do
      let(:has_evidence_of_benefit) { 'false' }

      it 'updates the dwp_override model' do
        dwp_override = legal_aid_application.reload.dwp_override
        expect(dwp_override.has_evidence_of_benefit).to be false
      end

      it 'redirects to the tbc_design page' do
        expect(response).to redirect_to(providers_legal_aid_application_applicant_employed_index_path(legal_aid_application))
      end

      it 'updates the state machine type' do
        expect(legal_aid_application.reload.state_machine).to be_a_kind_of NonPassportedStateMachine
      end
    end

    context 'choose nothing' do
      let(:has_evidence_of_benefit) { nil }

      it 'show errors' do
        dwp_override = legal_aid_application.reload.dwp_override
        passporting_benefit = dwp_override.passporting_benefit.titleize
        error = I18n.t('activemodel.errors.models.dwp_override.attributes.has_evidence_of_benefit.blank', passporting_benefit: passporting_benefit)
        expect(response.body).to include(error)
      end

      it 'updates the state machine type' do
        expect(legal_aid_application.reload.state_machine).to be_a_kind_of NonPassportedStateMachine
      end
    end

    context 'Form submitted with Save as draft button' do
      let(:params) { { draft_button: 'Save as draft' } }

      it 'redirects to the list of applications' do
        expect(response).to redirect_to providers_legal_aid_applications_path
      end
    end
  end
end
