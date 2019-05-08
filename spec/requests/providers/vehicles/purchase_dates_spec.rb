require 'rails_helper'

RSpec.describe Providers::Vehicles::PurchaseDatesController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_vehicle }
  let(:vehicle) { legal_aid_application.vehicle }
  let(:login) { login_as legal_aid_application.provider }

  before { login }

  describe 'GET /providers/applications/:legal_aid_application_id/vehicle/purchase_date' do
    subject do
      get providers_legal_aid_application_vehicles_purchase_date_path(legal_aid_application)
    end

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end

    context 'with an existing purchase date' do
      let(:purchase_date) { 5.days.ago.to_date }
      let(:vehicle) { create :vehicle, purchased_on: purchase_date }
      let(:legal_aid_application) { create :legal_aid_application, vehicle: vehicle  }

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

    context 'when the provider is not authenticated' do
      let(:login) { nil }
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/vehicle/purchase_date' do
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
    let(:next_url) { providers_legal_aid_application_vehicles_regular_use_path(legal_aid_application) }
    let(:submit_button) { {} }

    subject do
      patch(
        providers_legal_aid_application_vehicles_purchase_date_path(legal_aid_application),
        params: params.merge(submit_button)
      )
    end

    it 'updates vehicle' do
      subject
      expect(vehicle.reload.purchased_on).to eq(purchase_date)
    end

    it 'redirects to next step' do
      subject
      expect(response).to redirect_to(next_url)
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
        expect(response.body).to include('Date your client bought the vehicle must be in the past')
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
        expect(vehicle.reload.purchased_on).to eq(purchase_date)
      end

      context 'with blank entry' do
        let(:params) do
          {
            vehicle: {
              purchased_on_year: '',
              purchased_on_month: '',
              purchased_on_day: ''

            }
          }
        end

        it "redirects provider to provider's applications page" do
          subject
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end

        it 'sets the application as draft' do
          expect { subject }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
        end

        it 'leaves value blank' do
          expect(vehicle.reload.purchased_on).to be_blank
        end
      end
    end

    context 'when the provider is not authenticated' do
      let(:login) { nil }
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end
  end
end
