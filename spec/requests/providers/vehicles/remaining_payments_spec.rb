require 'rails_helper'

RSpec.describe Providers::Vehicles::RemainingPaymentsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_non_passported_state_machine, :with_vehicle }
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
    let(:next_url) { providers_legal_aid_application_vehicles_age_path(legal_aid_application) }
    let(:submit_button) { {} }

    subject do
      patch(
        providers_legal_aid_application_vehicles_remaining_payment_path(legal_aid_application),
        params: params.merge(submit_button)
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

    context 'with payments remaining false' do
      let(:payments_remain) { 'false' }

      it 'sets vehicle payment remaining to zero' do
        subject
        expect(vehicle.reload.payment_remaining).to be_zero
      end
    end

    context 'with thousands separator' do
      let(:payment_remaining) { '4,300.0' }

      it 'updates the vehicle model' do
        subject
        expect(vehicle.reload.payment_remaining).to eq 4_300.0
      end
    end

    context 'with pound sign' do
      let(:payment_remaining) { '£4900.0' }

      it 'updates the vehicle model' do
        subject
        expect(vehicle.reload.payment_remaining).to eq 4_900.0
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
        expect(response.body).to include(I18n.t('activemodel.errors.models.vehicle.attributes.payment_remaining.blank'))
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
        expect(response.body).to include(I18n.t('activemodel.errors.models.vehicle.attributes.payment_remaining.not_a_number'))
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
        expect(vehicle.reload.payment_remaining).to eq(payment_remaining)
      end

      context 'with blank entry' do
        let(:payment_remaining) { '' }

        it "redirects provider to provider's applications page" do
          subject
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end

        it 'sets the application as draft' do
          expect { subject }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
        end

        it 'leaves value blank' do
          subject
          expect(vehicle.reload.payment_remaining).to be_blank
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
