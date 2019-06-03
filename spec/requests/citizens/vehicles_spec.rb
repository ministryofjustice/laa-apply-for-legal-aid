require 'rails_helper'

RSpec.describe Citizens::VehiclesController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :provider_submitted, :with_applicant }

  before do
    get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
  end

  describe 'GET /citizens/vehicle' do
    subject { get citizens_vehicle_path }

    before { subject }

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /citizens/vehicle' do
    let(:option) { 'foo' }
    let(:params) do
      { vehicle: { persisted: option } }
    end
    subject { post citizens_vehicle_path, params: params }

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'displays error' do
      subject
      expect(response.body).to include('govuk-error-summary')
    end

    context 'with option "true"' do
      let(:option) { 'true' }
      let(:next_url) { citizens_vehicles_estimated_value_path }

      it 'creates a vehicle' do
        expect { subject }.to change { Vehicle.count }.by(1)
        expect(legal_aid_application.reload.vehicle).to be_present
      end

      it 'redirects to estimated value' do
        subject
        expect(response).to redirect_to(next_url)
      end

      context 'and existing vehicle' do
        let(:legal_aid_application) { create :legal_aid_application, :provider_submitted, :with_applicant, :with_vehicle }

        it 'does not create a vehicle' do
          expect { subject }.not_to change { Vehicle.count }
        end

        it 'redirects to estimated value' do
          subject
          expect(response).to redirect_to(next_url)
        end
      end

      context 'while checking answers' do
        before { legal_aid_application.check_citizen_answers! }

        it 'redirects to estimated value' do
          subject
          expect(response).to redirect_to(next_url)
        end
      end
    end

    context 'with option "false"' do
      let(:option) { 'false' }
      let(:next_url) { citizens_savings_and_investment_path }

      it 'does not create a vehicle' do
        expect { subject }.not_to change { Vehicle.count }
      end

      it 'redirects to savings and investment' do
        subject
        expect(response).to redirect_to(next_url)
      end

      context 'while checking answers' do
        before { legal_aid_application.check_citizen_answers! }

        it 'redirects to check_answers page' do
          subject
          expect(response).to redirect_to(citizens_check_answers_path)
        end
      end

      context 'and existing vehicle' do
        let(:legal_aid_application) { create :legal_aid_application, :provider_submitted, :with_applicant, :with_vehicle }

        it 'delete existing vehicle' do
          expect { subject }.to change { Vehicle.count }.by(-1)
        end

        it 'redirects to savings and investment' do
          subject
          expect(response).to redirect_to(next_url)
        end
      end
    end
  end
end
