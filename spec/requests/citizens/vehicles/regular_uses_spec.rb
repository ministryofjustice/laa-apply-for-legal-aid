require 'rails_helper'

RSpec.describe Providers::Vehicles::RegularUsesController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :with_vehicle, :provider_submitted, :with_applicant }
  let(:vehicle) { legal_aid_application.vehicle }

  before do
    get citizens_legal_aid_application_path(legal_aid_application.generate_secure_id)
  end

  xdescribe 'GET /citizens/vehicle/regular_use' do
    subject { get citizens_vehicles_regular_use_path }

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end
  end

  xdescribe 'PATCH /citizens/vehicle/regular_use' do
    let(:used_regularly) { true }
    let(:params) do
      {
        vehicle: { used_regularly: used_regularly.to_s }
      }
    end
    let(:next_url) { citizens_savings_and_investment_path }

    subject { patch citizens_vehicles_regular_use_path, params: params }

    it 'updates vehicle' do
      subject
      expect(vehicle.reload).to be_used_regularly
    end

    it 'redirects to next step' do
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

    context 'with false' do
      let(:used_regularly) { false }

      it 'updates vehicle' do
        subject
        expect(vehicle.reload).not_to be_used_regularly
      end

      it 'redirects to next step' do
        subject
        expect(response).to redirect_to(next_url)
      end
    end

    context 'without value' do
      let(:params) { {} }

      it 'renders successfully' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'does not modify vehicle' do
        expect { subject }.not_to change { vehicle.reload.used_regularly }
      end

      it 'displays error' do
        subject
        expect(response.body).to include('govuk-error-summary')
        expect(response.body).to include('Select yes if the vehicle is in regular use')
      end
    end
  end
end
