require 'rails_helper'

RSpec.describe Citizens::Vehicles::EstimatedValuesController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_vehicle, :provider_submitted, :with_applicant }
  let(:vehicle) { legal_aid_application.vehicle }

  before do
    get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
  end

  describe 'GET /citizens/vehicle/estimated_value' do
    subject { get citizens_vehicles_estimated_value_path }

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /citizens/vehicle/estimated_value' do
    let(:estimated_value) { Faker::Commerce.price(2000..10_000) }
    let(:params) { { vehicle: { estimated_value: estimated_value } } }
    let(:next_url) { citizens_vehicles_remaining_payment_path }

    subject { patch citizens_vehicles_estimated_value_path, params: params }

    it 'updates vehicle' do
      subject
      expect(vehicle.reload.estimated_value).to eq(estimated_value)
    end

    it 'redirects to next step' do
      subject
      expect(response).to redirect_to(next_url)
    end

    context 'without value' do
      let(:estimated_value) { '' }

      it 'renders successfully' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'does not modify vehicle' do
        expect { subject }.not_to change { vehicle.reload.estimated_value }
      end

      it 'displays error' do
        subject
        expect(response.body).to include('govuk-error-summary')
        expect(response.body).to include('Enter the estimated value of the vehicle')
      end
    end

    context 'with a non-numeric value' do
      let(:estimated_value) { 'not a number' }

      it 'renders successfully' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'does not modify vehicle' do
        expect { subject }.not_to change { vehicle.reload.estimated_value }
      end

      it 'displays error' do
        subject
        expect(response.body).to include('govuk-error-summary')
        expect(response.body).to include('Estimated value must be an amount of money, like 5,000')
      end
    end
  end
end
