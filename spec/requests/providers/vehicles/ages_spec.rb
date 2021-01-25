require 'rails_helper'

RSpec.describe Providers::Vehicles::AgesController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_vehicle }
  let(:vehicle) { legal_aid_application.vehicle }
  let(:login) { login_as legal_aid_application.provider }

  before { login }

  describe 'GET /providers/applications/:legal_aid_application_id/vehicles/age' do
    subject do
      get providers_legal_aid_application_vehicles_age_path(legal_aid_application)
    end

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end

    context 'with existing older than three years flag' do
      let(:vehicle) { create :vehicle, purchased_on: nil, more_than_three_years_old: true }
      let(:legal_aid_application) { create :legal_aid_application, vehicle: vehicle }

      it 'renders successfully' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'page includes radio button yes which is checked' do
        subject
        parsed_response = Nokogiri::HTML.parse(response.body)
        true_radio = parsed_response.css('input#vehicle-more-than-three-years-old-true-field')
        expect(true_radio.attr('checked').text).to eq 'checked'
        false_radio = parsed_response.css('input#vehicle-more-than-three-years-old-false-field')
        expect(false_radio.attr('checked')).to be_nil
      end
    end

    context 'when the provider is not authenticated' do
      let(:login) { nil }
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/vehicle/purchase_date' do
    let(:params) do
      {
        vehicle: {
          more_than_three_years_old: true
        }
      }
    end
    let(:next_url) { providers_legal_aid_application_vehicles_regular_use_path(legal_aid_application) }
    let(:submit_button) { {} }

    subject do
      patch(
        providers_legal_aid_application_vehicles_age_path(legal_aid_application),
        params: params.merge(submit_button)
      )
    end

    it 'updates vehicle' do
      subject
      expect(vehicle.reload.more_than_three_years_old).to eq(true)
    end

    it 'redirects to next step' do
      subject
      expect(response).to redirect_to(next_url)
    end

    context 'without a value' do
      let(:params) do
        {
          vehicle: {
            more_than_three_years_old: nil
          }
        }
      end

      it 'renders successfully' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'does not modify vehicle' do
        expect { subject }.not_to change { vehicle.reload.more_than_three_years_old }
      end

      it 'displays error' do
        subject
        expect(response.body).to include('govuk-error-summary')
        expect(response.body).to include(I18n.t('activemodel.errors.models.vehicle.attributes.more_than_three_years_old.blank'))
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
        expect(vehicle.reload.more_than_three_years_old).to eq(true)
      end
    end

    context 'when the provider is not authenticated' do
      let(:login) { nil }
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end
  end
end
