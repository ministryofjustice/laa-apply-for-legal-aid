require 'rails_helper'

RSpec.describe Providers::HasEvidenceOfBenefitsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_dwp_override }
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
    let(:params) do
      {
        dwp_override: {
          has_evidence_of_benefit: has_evidence_of_benefit
        }
      }
    end

    subject { patch providers_legal_aid_application_has_evidence_of_benefit_path(legal_aid_application), params: params }

    context 'choose yes' do
      let(:has_evidence_of_benefit) { 'true' }

      it 'updates the dwp_override model' do
        dwp_override = legal_aid_application.reload.dwp_override
        expect(dwp_override.has_evidence_of_benefit).to be true
      end

      it 'redirects to the upload evidence_of_benefit page' do
        expect(response).to redirect_to(providers_legal_aid_application_evidence_of_benefit_path(legal_aid_application))
      end

      it 'updates the state machine type' do
        expect(legal_aid_application.reload.state_machine).to be_a_kind_of PassportedStateMachine
      end
    end

    context 'choose no' do
      let(:has_evidence_of_benefit) { 'false' }

      it 'updates the dwp_override model' do
        dwp_override = legal_aid_application.reload.dwp_override
        expect(dwp_override.has_evidence_of_benefit).to be false
      end

      it 'redirects to the tbc_design page' do
        expect(response.body).to include('[PLACEHOLDER] Page if provider has no evidence of benefit')
      end

      it 'updates the state machine type' do
        expect(legal_aid_application.reload.state_machine).to be_a_kind_of NonPassportedStateMachine
      end
    end

    context 'choose nothing' do
      let(:has_evidence_of_benefit) { nil }

      it 'show errors' do
        dwp_override = legal_aid_application.reload.dwp_override
        error = I18n.t('activemodel.errors.models.dwp_override.attributes.has_evidence_of_benefit.blank', passporting_benefit: dwp_override.passporting_benefit)
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
