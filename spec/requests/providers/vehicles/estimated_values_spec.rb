require 'rails_helper'

RSpec.describe Providers::Vehicles::EstimatedValuesController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_vehicle }
  let(:vehicle) { legal_aid_application.vehicle }
  let(:login) { login_as legal_aid_application.provider }

  before { login }

  describe 'GET /providers/applications/:legal_aid_application_id/vehicle/estimated_value' do
    subject do
      get providers_legal_aid_application_vehicles_estimated_value_path(legal_aid_application)
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

  describe 'PATCH /providers/applications/:legal_aid_application_id/vehicle/estimated_value' do
    let(:estimated_value) { Faker::Commerce.price(range: 2000..10_000) }
    let(:params) { { vehicle: { estimated_value: estimated_value } } }
    let(:next_url) { providers_legal_aid_application_vehicles_remaining_payment_path(legal_aid_application) }
    let(:submit_button) { {} }

    subject do
      patch(
        providers_legal_aid_application_vehicles_estimated_value_path(legal_aid_application),
        params: params.merge(submit_button)
      )
    end

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
        expect(response.body).to include(I18n.t('activemodel.errors.models.vehicle.attributes.estimated_value.blank'))
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
        expect(response.body).to include(I18n.t('activemodel.errors.models.vehicle.attributes.estimated_value.not_a_number'))
      end
    end

    context 'with a value containing a comma as a thousands separator' do
      let(:estimated_value) { '30,000.0' }

      it 'updates the estimated value' do
        subject
        expect(vehicle.reload.estimated_value).to eq 30_000.0
      end
    end

    context 'with currency sign' do
      let(:estimated_value) { '£25,300' }
      it 'updates the estimated value' do
        subject
        expect(vehicle.reload.estimated_value).to eq 25_300.0
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
        expect(vehicle.reload.estimated_value).to eq(estimated_value)
      end

      context 'with blank entry' do
        let(:estimated_value) { '' }

        it "redirects provider to provider's applications page" do
          subject
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end

        it 'sets the application as draft' do
          expect { subject }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
        end

        it 'leaves value blank' do
          expect(vehicle.reload.estimated_value).to be_blank
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
