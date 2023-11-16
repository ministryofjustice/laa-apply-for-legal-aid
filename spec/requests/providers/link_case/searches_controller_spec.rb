require "rails_helper"

RSpec.describe Providers::LinkCase::SearchesController do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:login) { login_as legal_aid_application.provider }
  let(:linkable_application) { create(:legal_aid_application, application_ref: "L-TVH-U0T") }

  before { login }

  describe "GET /providers/applications/:legal_aid_application_id/link_case/search" do
    subject(:get_request) { get providers_legal_aid_application_link_case_search_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { get_request }

      let(:login) { nil }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      it "renders page with expected heading" do
        get_request
        expect(response).to have_http_status(:ok)
        expect(page).to have_css("h1", text: "What is the LAA reference of the application you want to link to?")
      end
    end

    context "when linked application has already been created" do
      let(:linked_application) { create(:linked_application, lead_application_id: linkable_application.id, associated_application_id: legal_aid_application.id) }

      it "clears application on page load" do
        linked_application
        expect { get_request }.to change(LinkedApplication, :count).from(1).to(0)
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/link_case/search" do
    subject(:patch_request) { patch providers_legal_aid_application_link_case_search_path(legal_aid_application), params: }

    context "when valid search term is entered" do
      let(:params) { { linked_application: { search_ref: "L-TVH-U0T" } } }

      before { linkable_application }

      it "redirects to the linking case confirmation page" do
        patch_request
        expect(response).to redirect_to(providers_legal_aid_application_link_case_confirmation_path(legal_aid_application))
      end

      it "creates a linked application" do
        expect { patch_request }.to change(LinkedApplication, :count).from(0).to(1)
      end
    end

    context "when search term is blank" do
      let(:params) { { linked_application: { search_ref: "" }, continue_button: "Save and continue" } }

      it "stays on the page and shows a validation error" do
        patch_request
        expect(response).to have_http_status(:ok)
        expect(page).to have_error_message("Enter an application reference to search for")
      end

      it "does not create a linked application" do
        expect { patch_request }.not_to change(LinkedApplication, :count).from(0)
      end
    end

    context "when invalid search term is entered" do
      let(:params) { { linked_application: { search_ref: "testing" }, continue_button: "Save and continue" } }

      it "stays on the page and shows a validation error" do
        patch_request
        expect(response).to have_http_status(:ok)
        expect(page).to have_error_message("Enter a valid application reference to search for")
      end

      it "does not create a linked application" do
        expect { patch_request }.not_to change(LinkedApplication, :count).from(0)
      end
    end

    context "when application reference was not found" do
      let(:params) { { linked_application: { search_ref: "L-17B-RT1" }, continue_button: "Save and continue" } }

      it "stays on the page and shows a validation error" do
        patch_request
        expect(response).to have_http_status(:ok)
        expect(page).to have_error_message("The application reference entered cannot be found")
      end

      it "does not create a linked application" do
        expect { patch_request }.not_to change(LinkedApplication, :count).from(0)
      end
    end

    context "when form submitted using Save as draft button" do
      let(:params) { { linked_application: { search_ref: "L-TVH-U0T" }, draft_button: "Save and come back later" } }

      it "redirects provider to provider's applications page" do
        patch_request
        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end

      it "sets the application as draft" do
        expect { patch_request }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
      end

      it "does not link proceedings from source application" do
        expect { patch_request }.not_to change(LinkedApplication, :count).from(0)
      end
    end
  end
end
