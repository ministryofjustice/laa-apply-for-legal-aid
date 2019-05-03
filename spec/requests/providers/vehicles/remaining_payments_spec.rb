require 'rails_helper'

RSpec.describe Providers::Vehicles::RemainingPaymentsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_vehicle }
  let(:vehicle) { legal_aid_application.vehicle }
  let(:login) { login_as legal_aid_application.provider }

  before { login }

  describe 'GET /providers/applications/:legal_aid_application_id/vehicle/remaining_payment' do
    subject do
      get providers_legal_aid_application_vehicles_remaining_payment_path(legal_aid_application)
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

  describe 'PATCH /providers/applications/:legal_aid_application_id/vehicle/remaining_payment' do
    let(:payment_remaining) { Faker::Commerce.price(100..2000) }
    let(:payments_remain) { 'true' }
    let(:params) do
      {
        vehicle: {
          payment_remaining: payment_remaining,
          payments_remain: payments_remain
        }
      }
    end
    let(:next_url) { providers_legal_aid_application_vehicles_purchase_date_path(legal_aid_application) }

    subject do
      patch(
        providers_legal_aid_application_vehicles_remaining_payment_path(legal_aid_application),
        params: params
      )
    end

    it 'updates vehicle' do
      subject
      expect(vehicle.reload.payment_remaining).to eq(payment_remaining)
    end

    it 'redirects to next step' do
      subject
      expect(response).to redirect_to(next_url)
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

    context 'when the provider is not authenticated' do
      let(:login) { nil }
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end
  end
end
