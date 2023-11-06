require "rails_helper"

RSpec.describe Providers::LinkingCaseSearchesController do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:provider) { legal_aid_application.provider }

  before { login_as provider }

  describe "GET /providers/applications/:legal_aid_application_id/linking_case_search" do
    it "renders page with expected heading" do
      get providers_legal_aid_application_linking_case_search_path(legal_aid_application)
      expect(response).to have_http_status(:ok)
      expect(page).to have_css("h1", text: "What is the LAA reference of the application you want to link to?")
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/linking_case_search" do
    before { patch providers_legal_aid_application_linking_case_search_path(legal_aid_application), params: }

    context "when valid search term is entered" do
      let(:params) { { legal_aid_application: { search_ref: }, continue_button: "Save and continue" } }
      let(:another_application) { create(:legal_aid_application) }
      let(:search_ref) { another_application.application_ref }

      it "redirects to the address_lookup page" do
        expect(response).to redirect_to(providers_legal_aid_application_address_lookup_path(legal_aid_application))
      end
    end

    context "when invalid search term is entered" do
      let(:params) { { legal_aid_application: { search_ref: "" }, continue_button: "Save and continue" } }

      it "stays on the page if there is a validation error" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_error_message("can't be blank")
      end
    end

    def have_error_message(text)
      have_css(".govuk-error-summary__list > li", text:)
    end
  end
end
