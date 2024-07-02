require "rails_helper"

RSpec.describe Providers::EndOfApplicationsController do
  let(:legal_aid_application) { create(:legal_aid_application, :assessment_submitted) }
  let(:login) { login_as legal_aid_application.provider }

  before { login }

  describe "GET /providers/applications/:legal_aid_application_id/end_of_application" do
    subject(:get_request) do
      get providers_legal_aid_application_end_of_application_path(legal_aid_application)
    end

    it "renders successfully" do
      get_request
      expect(response).to have_http_status(:ok)
    end

    it "displays reference" do
      get_request
      expect(response.body).to include(legal_aid_application.application_ref)
    end

    it "has a link to the feedback page" do
      get_request
      expect(response.body).to include(new_feedback_path)
    end

    context "when the provider is not authenticated" do
      let(:login) { nil }

      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "with another provider" do
      let(:login) { login_as create(:provider) }

      before { get_request }

      it "redirects to access denied error" do
        expect(response).to redirect_to(error_path(:access_denied))
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/end_of_application" do
    subject(:patch_request) do
      patch(
        providers_legal_aid_application_end_of_application_path(legal_aid_application),
        params:,
      )
    end

    let(:params) { {} }

    it "redirects to next page" do
      patch_request
      expect(response).to have_http_status(:redirect)
    end

    context "when Submitted using the draft button" do
      let(:params) { { draft_button: "Save as draft" } }

      it "redirects provider to provider's applications page" do
        patch_request
        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end

      it "sets the application as draft" do
        expect { patch_request }.not_to change { legal_aid_application.reload.draft? }
      end
    end

    context "when the provider is not authenticated" do
      let(:login) { nil }

      before { patch_request }

      it_behaves_like "a provider not authenticated"
    end

    context "with another provider" do
      let(:login) { login_as create(:provider) }

      before { patch_request }

      it "redirects to access denied error" do
        expect(response).to redirect_to(error_path(:access_denied))
      end
    end
  end
end
