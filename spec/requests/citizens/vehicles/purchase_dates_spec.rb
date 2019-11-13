require 'rails_helper'

RSpec.describe Citizens::Vehicles::PurchaseDatesController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_vehicle, :provider_submitted, :with_applicant }
  let(:vehicle) { legal_aid_application.vehicle }

  before do
    get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
  end

  describe 'GET /citizens/vehicle/purchase_date' do
    subject { get citizens_vehicles_purchase_date_path }

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end

    context 'with an existing purchase date' do
      let(:purchase_date) { 5.days.ago.to_date }
      let(:vehicle) { create :vehicle, purchased_on: purchase_date }
      let(:legal_aid_application) { create :legal_aid_application, :provider_submitted, :with_applicant, vehicle: vehicle }

      it 'renders successfully' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'page includes date' do
        subject
        expect(response.body).to include(purchase_date.year.to_s)
        expect(response.body).to include(purchase_date.month.to_s)
        expect(response.body).to include(purchase_date.day.to_s)
      end
    end
  end

  describe 'PATCH /citizens/vehicle/purchase_date' do
    let(:purchase_date) { 5.days.ago.to_date }
    let(:params) do
      {
        vehicle: {
          purchased_on_year: purchase_date.year,
          purchased_on_month: purchase_date.month,
          purchased_on_day: purchase_date.day
        }
      }
    end
    let(:next_url) { citizens_vehicles_regular_use_path }

    subject { patch citizens_vehicles_purchase_date_path, params: params }

    it 'updates vehicle' do
      subject
      expect(vehicle.reload.purchased_on).to eq(purchase_date)
    end

    it 'redirects to next step' do
      subject
      expect(response).to redirect_to(next_url)
    end

    context 'alphanumeric purchase date' do
      let(:params) do
        {
          vehicle: {
            purchased_on_year: purchase_date.year,
            purchased_on_month: purchase_date.month,
            purchased_on_day: '5s'
          }
        }
      end

      it 'errors' do
        subject
        expect(unescaped_response_body).to include('There is a problem')
        expect(unescaped_response_body).to include('Enter a valid date')
      end
    end

    context 'without a value' do
      let(:params) do
        {
          vehicle: {
            purchased_on_year: purchase_date.year,
            purchased_on_month: '',
            purchased_on_day: purchase_date.day
          }
        }
      end

      it 'renders successfully' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'does not modify vehicle' do
        expect { subject }.not_to change { vehicle.reload.purchased_on }
      end

      it 'displays error' do
        subject
        expect(response.body).to include('govuk-error-summary')
        expect(response.body).to include('Enter a valid date')
      end
    end

    context 'with an invalid date' do
      let(:params) do
        {
          vehicle: {
            purchased_on_year: purchase_date.year,
            purchased_on_month: '33',
            purchased_on_day: purchase_date.day
          }
        }
      end

      it 'renders successfully' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'does not modify vehicle' do
        expect { subject }.not_to change { vehicle.reload.purchased_on }
      end

      it 'displays error' do
        subject
        expect(response.body).to include('govuk-error-summary')
        expect(response.body).to include('Enter a valid date')
      end
    end

    context 'with a date in the future' do
      let(:purchase_date) { 3.days.from_now.to_date }

      it 'renders successfully' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'does not modify vehicle' do
        expect { subject }.not_to change { vehicle.reload.purchased_on }
      end

      it 'displays error' do
        subject
        expect(response.body).to include('govuk-error-summary')
        expect(response.body).to include('Date you bought the vehicle must be in the past')
      end
    end
  end
end
