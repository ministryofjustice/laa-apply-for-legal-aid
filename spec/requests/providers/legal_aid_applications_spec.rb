require 'rails_helper'

RSpec.describe 'providers legal aid application requests', type: :request do
  describe 'GET /providers/applications' do
    before { get providers_legal_aid_applications_path }

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /providers/applications' do
    subject { post providers_legal_aid_applications_path }
    let(:legal_aid_application) { LegalAidApplication.last }

    it 'creates a new application record' do
      expect { subject }.to change { LegalAidApplication.count }.by(1)
    end

    it 'creates an associated other_assets_declaration' do
      expect { subject }.to change { OtherAssetsDeclaration.count }.by(1)
    end

    it 'redirects to proceedings types' do
      subject
      expect(response).to redirect_to(
        providers_legal_aid_application_proceedings_type_path(legal_aid_application)
      )
    end
  end
end
