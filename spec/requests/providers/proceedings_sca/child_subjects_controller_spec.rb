require "rails_helper"

RSpec.describe Providers::ProceedingsSCA::ChildSubjectsController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[da001]) }
  let(:login_provider) { login_as legal_aid_application.provider }

  describe "GET /providers/applications/:id/child_subjects" do
    subject(:get_request) { get providers_legal_aid_application_child_subject_path(legal_aid_application) }

    before do
      login_provider
      get_request
    end

    it "renders show with ok status" do
      expect(response).to have_http_status(:ok).and render_template("providers/proceedings_sca/child_subjects/show")
    end

    context "when not authenticated" do
      let(:login_provider) { nil }

      it_behaves_like "a provider not authenticated"
    end

    context "when authenticated as a different provider" do
      let(:login_provider) { login_as create(:provider) }

      it_behaves_like "an authenticated provider from a different firm"
    end
  end

  describe "PATCH /providers/applications/:id/child_subjects" do
    subject(:patch_request) do
      patch(providers_legal_aid_application_child_subject_path(legal_aid_application, params:))
    end

    let(:params) do
      {
        binary_choice_form: {
          child_subject:,
        },
      }
    end

    before { login_provider }

    context "when the provider responds yes" do
      let(:child_subject) { "true" }

      it "redirects to the next page" do
        patch_request
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when the provider responds no" do
      let(:child_subject) { "false" }

      it "redirects to the next page" do
        patch_request
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(providers_legal_aid_application_sca_interrupt_path(legal_aid_application, "child_subject"))
      end
    end

    context "when the provider does not provide a response" do
      let(:child_subject) { "" }

      it "renders the same page with an error message" do
        patch_request
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Select yes if your client is the child subject of this proceeding").twice
      end
    end

    context "with form submitted using Save as draft button" do
      let(:params) { { draft_button: "Save and come back later" } }

      it "redirects provider to provider's applications page" do
        patch_request
        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end

      it "sets the application as draft" do
        expect { patch_request }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
      end
    end
  end
end
