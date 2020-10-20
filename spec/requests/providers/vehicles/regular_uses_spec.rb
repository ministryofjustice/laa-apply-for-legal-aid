require 'rails_helper'

RSpec.describe Providers::Vehicles::RegularUsesController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_vehicle }
  let(:vehicle) { legal_aid_application.vehicle }
  let(:login) { login_as legal_aid_application.provider }

  before { login }

  describe 'GET /providers/applications/:legal_aid_application_id/vehicle/regular_use' do
    subject do
      get providers_legal_aid_application_vehicles_regular_use_path(legal_aid_application)
    end

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end

    context 'when the provider is not authenticated' do
      let(:login) { nil }
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/vehicle/regular_use' do
    let(:used_regularly) { true }
    let(:params) do
      {
        vehicle: { used_regularly: used_regularly.to_s }
      }
    end
    let(:next_url) { providers_legal_aid_application_applicant_bank_account_path(legal_aid_application) }
    let(:submit_button) { {} }

    subject do
      patch(
        providers_legal_aid_application_vehicles_regular_use_path(legal_aid_application),
        params: params.merge(submit_button)
      )
    end

    it 'updates vehicle' do
      subject
      expect(vehicle.reload).to be_used_regularly
    end

    it 'redirects to next step' do
      subject
      expect(response).to redirect_to(next_url)
    end

    context 'with false' do
      let(:used_regularly) { false }

      it 'updates vehicle' do
        subject
        expect(vehicle.reload).not_to be_used_regularly
      end

      it 'redirects to next step in the non-passported journey' do
        subject
        expect(response).to redirect_to(next_url)
      end
    end

    context 'with false on a passported journey' do
      let(:legal_aid_application) { create :legal_aid_application, :with_vehicle, :passported }
      let(:used_regularly) { false }

      it 'updates vehicle' do
        subject
        expect(vehicle.reload).not_to be_used_regularly
      end

      it 'redirects to next step in the non-passported journey' do
        subject
        expect(response).to redirect_to(providers_legal_aid_application_offline_account_path(legal_aid_application))
      end
    end

    context 'without value' do
      let(:params) { {} }

      it 'renders successfully' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'does not modify vehicle' do
        expect { subject }.not_to change { vehicle.reload.used_regularly }
      end

      it 'displays error' do
        subject
        expect(response.body).to include('govuk-error-summary')
        expect(response.body).to include(I18n.t('activemodel.errors.models.vehicle.attributes.used_regularly.blank'))
      end
    end

    context 'Form submitted using Save as draft button' do
      let(:submit_button) { { draft_button: 'Save as draft' } }

      it "redirects provider to provider's applications page" do
        subject
        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end

      it 'sets the application as draft' do
        expect { subject }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
      end

      it 'updates vehicle' do
        subject
        expect(vehicle.reload).to be_used_regularly
      end

      context 'with blank entry' do
        let(:used_regularly) { '' }

        it "redirects provider to provider's applications page" do
          subject
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end

        it 'sets the application as draft' do
          expect { subject }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
        end

        it 'leaves value blank' do
          expect(vehicle.reload.used_regularly).to be_blank
        end
      end
    end

    context 'when the provider is not authenticated' do
      let(:login) { nil }
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'while checking answers' do
      let(:legal_aid_application) { create :legal_aid_application, :with_non_passported_state_machine, :checking_non_passported_means }

      it 'redirects to non-passported check answers page' do
        subject
        expect(response).to redirect_to(providers_legal_aid_application_means_summary_path(legal_aid_application))
      end
    end

    context 'while checking passported answers' do
      let(:legal_aid_application) { create :legal_aid_application, :with_passported_state_machine, :checking_passported_answers }

      it 'redirects to passported check answers page' do
        subject
        expect(response).to redirect_to(providers_legal_aid_application_check_passported_answers_path(legal_aid_application))
      end
    end
  end
end
