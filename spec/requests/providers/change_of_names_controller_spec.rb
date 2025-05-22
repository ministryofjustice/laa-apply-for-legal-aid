require "rails_helper"

RSpec.describe Providers::ChangeOfNamesController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[da001]) }
  let(:login_provider) { login_as legal_aid_application.provider }

  describe "GET /providers/applications/:id/change_of_names" do
    subject(:get_request) { get providers_legal_aid_application_change_of_names_path(legal_aid_application) }

    before do
      login_provider
      get_request
    end

    it "renders show with ok status" do
      expect(response).to have_http_status(:ok).and render_template("providers/change_of_names/show")
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

  describe "PATCH /providers/applications/:id/change_of_names" do
    subject(:patch_request) do
      patch(providers_legal_aid_application_change_of_names_path(legal_aid_application, params:))
    end

    let(:params) do
      {
        binary_choice_form: {
          change_of_name:,
        },
      }
    end

    before { login_provider }

    context "when the provider responds yes" do
      let(:change_of_name) { "true" }

      it "redirects to the next page" do
        patch_request
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(providers_legal_aid_application_change_of_names_interrupt_path(legal_aid_application))
      end
    end

    context "when the provider responds no" do
      let(:change_of_name) { "false" }

      it "redirects to the next page" do
        patch_request
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when the provider does not provide a response" do
      let(:change_of_name) { "" }

      it "renders the same page with an error message" do
        patch_request
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Select yes if this proceeding is for a change of name application").twice
      end
    end

    context "with form submitted using Save as draft button" do
      let(:params) { { draft_button: "Save and come back later" } }

      it "redirects provider to provider's applications page" do
        patch_request
        expect(response).to redirect_to(in_progress_providers_legal_aid_applications_path)
      end

      it "sets the application as draft" do
        expect { patch_request }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
      end
    end
  end
end
