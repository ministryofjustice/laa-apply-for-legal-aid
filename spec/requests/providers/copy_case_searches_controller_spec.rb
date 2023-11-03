require "rails_helper"

RSpec.describe Providers::CopyCaseSearchesController do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:provider) { legal_aid_application.provider }
  let(:login) { login_as provider }

  before { login }

  describe "GET /providers/applications/:legal_aid_application_id/copy_case_search" do
    subject(:get_request) do
      get providers_legal_aid_application_copy_case_search_path(legal_aid_application)
    end

    before { get_request }

    context "when the provider is not authenticated" do
      let(:login) { nil }

      it_behaves_like "a provider not authenticated"
    end

    it "renders page with expected heading" do
      expect(response).to have_http_status(:ok)
      expect(page).to have_css(
        "h1",
        text: "What is the LAA reference of the application you want to copy?",
      )
    end
  end

  describe "PATCH /providers/:application_id/copy_case_search" do
    subject(:patch_request) { patch providers_legal_aid_application_copy_case_search_path(legal_aid_application), params: }

    before do
      allow(Setting).to receive(:linked_applications?).and_return(enable_linked_applications)
    end

    let(:enable_linked_applications) { true }

    context "when the provider is not authenticated" do
      let(:login) { nil }
      let(:params) { {} }

      before { patch_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when a valid application reference is provided" do
      let(:params) { { legal_aid_application: { search_ref: source_application.application_ref } } }
      let(:source_application) { create(:legal_aid_application, application_ref: "L-TVH-U0T") }

      it "redirects to the copy case confirmation page" do
        patch_request
        expect(response).to redirect_to(providers_legal_aid_application_copy_case_confirmation_path(legal_aid_application))
      end

      it "stores the source application's id in the session" do
        patch_request
        expect(request.session[:copy_case_id]).to eq source_application.id
      end
    end

    context "when an invalid application reference is provided" do
      let(:params) { { legal_aid_application: { search_ref: "INVALID-APP-REF" } } }

      it "stays on the page and displays validation error" do
        patch_request
        expect(response).to have_http_status(:ok)
        expect(page).to have_error_message("Enter a valid application reference to search for")
      end

      it "does not store the source application's id in the session" do
        patch_request
        expect(request.session[:copy_case_id]).to be_nil
      end
    end

    context "when a valid format but non-existant application reference is provided" do
      let(:params) { { legal_aid_application: { search_ref: "L-FFF-FFF" } } }

      it "stays on the page and displays validation error" do
        patch_request
        expect(response).to have_http_status(:ok)
        expect(page).to have_error_message("The application reference entered cannot be found")
      end

      it "does not store the source application's id in the session" do
        patch_request
        expect(request.session[:copy_case_id]).to be_nil
      end
    end

    context "when no application reference is provided" do
      let(:params) { { legal_aid_application: { search_ref: "" } } }

      it "stays on the page and displays validation error" do
        patch_request
        expect(response).to have_http_status(:ok)
        expect(page).to have_error_message("Enter an application reference to search for")
      end

      it "does not store the source application's id in the session" do
        patch_request
        expect(request.session[:copy_case_id]).to be_nil
      end
    end
  end
end
