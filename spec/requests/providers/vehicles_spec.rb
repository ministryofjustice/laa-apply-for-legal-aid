require 'rails_helper'

RSpec.describe Providers::VehiclesController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application }
  let(:login) { login_as legal_aid_application.provider }

  before { login }

  describe 'GET /providers/applications/:legal_aid_application_id/vehicle' do
    subject { get providers_legal_aid_application_vehicle_path(legal_aid_application) }

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

  describe 'DELETE /providers/applications/:legal_aid_application_id/vehicle' do

  end

  describe 'POST /providers/applications/:legal_aid_application_id/vehicle' do

  end
end
