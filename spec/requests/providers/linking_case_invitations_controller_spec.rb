require "rails_helper"

RSpec.describe Providers::LinkingCaseInvitationsController do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:provider) { legal_aid_application.provider }

  before { login_as provider }

  describe "GET /providers/applications/:legal_aid_application_id/linking_case_invitation" do
    it "renders page with expected heading" do
      get providers_legal_aid_application_linking_case_invitation_path(legal_aid_application)
      expect(response).to have_http_status(:ok)
      expect(page).to have_css("h1", text: "Do you want to link an application to your application?")
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/linking_case_invitation" do
    before { patch providers_legal_aid_application_linking_case_invitation_path(legal_aid_application), params: }

    context "when form submitted with Save as draft button" do
      let(:params) { { legal_aid_application: { link_case: "" }, draft_button: "Save and come back later" } }

      it "redirects to the list of applications" do
        expect(response).to redirect_to providers_legal_aid_applications_path
      end
    end

    context "when no chosen" do
      let(:params) { { legal_aid_application: { link_case: "false" } } }

      it "redirects to the address_lookup page" do
        expect(response).to redirect_to(providers_legal_aid_application_address_lookup_path(legal_aid_application))
      end
    end

    context "when yes chosen" do
      let(:params) { { legal_aid_application: { link_case: "true" } } }

      it "redirects to linking_case_search page" do
        expect(response).to redirect_to(providers_legal_aid_application_linking_case_search_path(legal_aid_application))
      end
    end

    context "when no answer chosen" do
      let(:params) { { legal_aid_application: { link_case: "" }, continue_button: "Save and continue" } }

      it "stays on the page if there is a validation error" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_error_message("Select yes if you would like to link an application to your application")
      end
    end

    def have_error_message(text)
      have_css(".govuk-error-summary__list > li", text:)
    end
  end
end
