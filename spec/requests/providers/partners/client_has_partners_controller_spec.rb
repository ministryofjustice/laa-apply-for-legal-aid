require "rails_helper"

RSpec.describe Providers::Partners::ClientHasPartnersController do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:provider) { legal_aid_application.provider }

  before { login_as provider }

  describe "GET /providers/applications/:legal_aid_application_id/client_has_partner" do
    subject! do
      get providers_legal_aid_application_client_has_partner_path(legal_aid_application)
    end

    it "renders page with expected heading" do
      expect(response).to have_http_status(:ok)
      expect(page).to have_css(
        "h1",
        text: "Does your client have a partner?",
      )
    end
  end

  describe "PATCH /providers/:application_id/client_has_partner" do
    subject(:patch_has_partner) { patch providers_legal_aid_application_client_has_partner_path(legal_aid_application), params: }

    before { patch_has_partner }

    context "when form submitted with Save as draft button" do
      let(:params) { { applicant: { has_partner: "" }, draft_button: "Save and come back later" } }

      it "redirects to the list of applications" do
        expect(response).to redirect_to submitted_providers_legal_aid_applications_path
      end
    end

    context "when yes chosen" do
      let(:params) { { applicant: { has_partner: "true" } } }

      it "redirects to the next page" do
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when no chosen" do
      let(:params) { { applicant: { has_partner: "false" } } }

      it "redirects to the next page" do
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when no answer chosen" do
      let(:params) { { applicant: { has_partner: "" }, continue_button: "Save and continue" } }

      it "stays on the page if there is a validation error" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_error_message("Select yes if the client has a partner")
      end
    end
  end
end
