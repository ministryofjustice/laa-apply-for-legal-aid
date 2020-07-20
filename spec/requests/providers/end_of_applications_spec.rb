require 'rails_helper'

RSpec.describe Providers::EndOfApplicationsController, type: :request do
  let(:legal_aid_application) { create :legal_aid_application, :assessment_submitted }
  let(:login) { login_as legal_aid_application.provider }

  before { login }

  describe 'GET /providers/applications/:legal_aid_application_id/end_of_application' do
    subject do
      get providers_legal_aid_application_end_of_application_path(legal_aid_application)
    end

    it 'renders successfully' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'displays reference' do
      subject
      expect(response.body).to include(legal_aid_application.application_ref)
    end

    it 'has a link to the feedback page' do
      subject
      expect(response.body).to include(new_feedback_path)
    end

    context 'when the provider is not authenticated' do
      let(:login) { nil }
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'with another provider' do
      let(:login) { login_as create(:provider) }
      before { subject }

      it 'redirects to access denied error' do
        expect(response).to redirect_to(error_path(:access_denied))
      end
    end
  end

  describe 'PATCH /providers/applications/:legal_aid_application_id/end_of_application' do
    let(:params) { {} }

    subject do
      patch(
        providers_legal_aid_application_end_of_application_path(legal_aid_application),
        params: params
      )
    end

    it 'redirects to next page' do
      subject
      expect(response).to redirect_to(flow_forward_path)
    end

    context 'Submitted using draft button' do
      let(:params) { { draft_button: 'Save as draft' } }

      it "redirects provider to provider's applications page" do
        subject
        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end

      it 'sets the application as draft' do
        expect { subject }.not_to change { legal_aid_application.reload.draft? }
      end
    end

    context 'when the provider is not authenticated' do
      let(:login) { nil }
      before { subject }
      it_behaves_like 'a provider not authenticated'
    end

    context 'with another provider' do
      let(:login) { login_as create(:provider) }
      before { subject }

      it 'redirects to access denied error' do
        expect(response).to redirect_to(error_path(:access_denied))
      end
    end
  end
end
