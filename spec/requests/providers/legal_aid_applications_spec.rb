require 'rails_helper'

RSpec.describe 'providers legal aid application requests', type: :request do
  describe 'GET /providers/applications' do
    let!(:legal_aid_application) { create :legal_aid_application }
    let(:provider) { legal_aid_application.provider }
    let(:other_provider) { create(:provider) }
    subject { get providers_legal_aid_applications_path }

    context 'when the provider is not authenticated' do
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'when the provider is authenticated' do
      before do
        login_as provider
        subject
      end

      it 'returns http success' do
        expect(response).to have_http_status(:ok)
      end

      it "includes a link to the legal aid application's default start path" do
        expect(response.body).to include(providers_legal_aid_application_proceedings_types_path(legal_aid_application))
      end

      context 'when legal_aid_application current path set' do
        let!(:legal_aid_application) { create :legal_aid_application, provider_step: :applicants }

        it "includes a link to the legal aid application's current path" do
          expect(response.body).to include(providers_legal_aid_application_applicant_path(legal_aid_application))
        end
      end
    end

    context 'when another provider is authenticated' do
      before do
        login_as other_provider
        subject
      end

      it 'has no current applications' do
        expect(response.body).not_to include('Current applications')
      end
    end
  end

  describe 'POST /providers/applications' do
    subject { post providers_legal_aid_applications_path }
    let(:legal_aid_application) { LegalAidApplication.last }

    context 'when the provider is authenticated' do
      before do
        login_as create(:provider)
      end

      it 'creates a new application record' do
        expect { subject }.to change { LegalAidApplication.count }.by(1)
      end

      it 'creates an associated other_assets_declaration' do
        expect { subject }.to change { OtherAssetsDeclaration.count }.by(1)
      end

      it 'redirects to applicant details page ' do
        subject
        expect(response).to redirect_to(providers_legal_aid_application_applicant_path(legal_aid_application))
      end
    end
  end
end
