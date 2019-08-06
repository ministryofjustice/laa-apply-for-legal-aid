require 'rails_helper'

RSpec.describe Providers::Vehicles::RemainingPaymentsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_vehicle, :provider_submitted, :with_applicant }
  let(:vehicle) { legal_aid_application.vehicle }

  before do
    get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
  end

  describe 'GET /citizens/vehicle/remaining_payment' do
    subject { get citizens_vehicles_remaining_payment_path }

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /citizens/vehicle/remaining_payment' do
    let(:payment_remaining) { Faker::Commerce.price(range: 100..2000) }
    let(:payments_remain) { 'true' }
    let(:params) do
      {
        vehicle: {
          payment_remaining: payment_remaining,
          payments_remain: payments_remain
        }
      }
    end
    let(:next_url) { citizens_vehicles_purchase_date_path }

    subject { patch citizens_vehicles_remaining_payment_path, params: params }

    it 'updates vehicle' do
      subject
      expect(vehicle.reload.payment_remaining).to eq(payment_remaining)
    end

    it 'redirects to next step' do
      subject
      expect(response).to redirect_to(next_url)
    end

    context 'with payments remaining false' do
      let(:payments_remain) { 'false' }

      it 'sets vehicle payment remaining to zero' do
        subject
        expect(vehicle.reload.payment_remaining).to be_zero
      end
    end

    context 'without value' do
      let(:payment_remaining) { '' }

      it 'renders successfully' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'does not modify vehicle' do
        expect { subject }.not_to change { vehicle.reload.payment_remaining }
      end

      it 'displays error' do
        subject
        expect(response.body).to include('govuk-error-summary')
        expect(response.body).to include('Enter the amount left to pay')
      end
    end

    context 'with a non-numeric value' do
      let(:payment_remaining) { 'not a number' }

      it 'renders successfully' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'does not modify vehicle' do
        expect { subject }.not_to change { vehicle.reload.payment_remaining }
      end

      it 'displays error' do
        subject
        expect(response.body).to include('govuk-error-summary')
        expect(response.body).to include('The amount left to pay must be an amount of money, like 5,000')
      end
    end
  end
end
