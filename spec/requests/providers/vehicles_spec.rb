require 'rails_helper'

RSpec.describe Providers::VehiclesController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application }
  let(:login) { login_as legal_aid_application.provider }

  before { login }

  describe 'GET /providers/applications/:legal_aid_application_id/vehicle' do
    subject { get providers_legal_aid_application_vehicle_path(legal_aid_application) }

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

  describe 'POST /providers/applications/:legal_aid_application_id/vehicle' do
    let(:option) { 'foo' }
    let(:params) { { exists: option } }
    subject do
      post(
        providers_legal_aid_application_vehicle_path(legal_aid_application),
        params: params
      )
    end

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'displays error' do
      subject
      expect(response.body).to include('govuk-error-summary')
    end

    context 'when the provider is not authenticated' do
      let(:login) { nil }
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'with option "yes"' do
      let(:option) { 'yes' }
      let(:target_url) do
        providers_legal_aid_application_vehicle_vehicles_estimated_value_path(legal_aid_application)
      end

      it 'creates a vehicle' do
        expect { subject }.to change { Vehicle.count }.by(1)
        expect(legal_aid_application.reload.vehicle).to be_present
      end

      it 'redirects to estimated value' do
        subject
        expect(response).to redirect_to(target_url)
      end

      context 'and exiting vehicle' do
        let(:legal_aid_application) { create :legal_aid_application, :with_vehicle }

        it 'does not create a vehicle' do
          expect { subject }.not_to change { Vehicle.count }
        end

        it 'redirects to estimated value' do
          subject
          expect(response).to redirect_to(target_url)
        end
      end
    end

    context 'with option "no"' do
      let(:option) { 'no' }
      let(:target_url) do
        providers_legal_aid_application_savings_and_investment_path(legal_aid_application)
      end

      it 'does not create a vehicle' do
        expect { subject }.not_to change { Vehicle.count }
      end

      it 'redirects to savings and investment' do
        subject
        expect(response).to redirect_to(target_url)
      end

      context 'and exiting vehicle' do
        let(:legal_aid_application) { create :legal_aid_application, :with_vehicle }

        it 'does not create a vehicle' do
          expect { subject }.to change { Vehicle.count }.by(-1)
        end

        it 'redirects to savings and investment' do
          subject
          expect(response).to redirect_to(target_url)
        end
      end
    end
  end
end
