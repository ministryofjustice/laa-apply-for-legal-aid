require 'rails_helper'

RSpec.describe Providers::HasEvidenceOfBenefitsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_dwp_override, :checking_applicant_details, :with_proceeding_types, :with_delegated_functions }
  let(:login) { login_as legal_aid_application.provider }
  let(:enable_evidence_upload_flag) { false }

  before do
    Setting.setting.update!(enable_evidence_upload: enable_evidence_upload_flag)
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

    context 'evidence upload setting' do
      context 'when FALSE' do
        it 'tells the user that the caseworker will ask for evidence' do
          expect(response.body.gsub('&#39;', %('))).to include I18n.t('providers.has_evidence_of_benefits.show.hint')
        end

        it 'does not have a radio button hint' do
          expect(response.body).not_to include I18n.t('providers.has_evidence_of_benefits.show.radio_hint_yes')
        end
      end

      context 'when TRUE' do
        let(:enable_evidence_upload_flag) { true }

        it 'does not mention the caseworker in the main hint' do
          expect(response.body).to include I18n.t('providers.has_evidence_of_benefits.show.evidence_hint')
        end

        it 'shows hint about uploading later in the hint for the Yes radio' do
          expect(response.body.gsub('&#39;', %('))).to include I18n.t('providers.has_evidence_of_benefits.show.radio_hint_yes')
        end
      end
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

      it 'redirects to the proceeding types page' do
        expect(response).to redirect_to(providers_legal_aid_application_proceedings_types_path(legal_aid_application))
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
