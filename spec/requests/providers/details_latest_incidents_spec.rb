require 'rails_helper'

RSpec.describe Providers::DetailsLatestIncidentsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application }
  let(:login_provider) { login_as legal_aid_application.provider }

  describe 'GET /providers/applications/:legal_aid_application_id/details_latest_incident' do
    subject do
      get providers_legal_aid_application_details_latest_incident_path(legal_aid_application)
    end

    before do
      login_provider
      subject
    end

    it 'renders successfully' do
      expect(response).to have_http_status(:ok)
    end

    context 'when not authenticated' do
      let(:login_provider) { nil }
      it_behaves_like 'a provider not authenticated'
    end

    context 'with an existing incident' do
      let(:incident) { create :incident }
      let(:legal_aid_application) { create :legal_aid_application, latest_incident: incident }

      it 'renders successfully' do
        expect(response).to have_http_status(:ok)
      end

      it 'displays incident data' do
        expect(response.body).to include(incident.details)
      end
    end
  end
end
