require "rails_helper"

RSpec.describe Providers::Partners::ContraryInterestsController do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:provider) { legal_aid_application.provider }

  before { login_as provider }

  describe "GET /providers/applications/:legal_aid_application_id/contrary_interest" do
    subject(:get_request) { get providers_legal_aid_application_contrary_interest_path(legal_aid_application) }

    it "renders page with expected heading" do
      get_request
      expect(response).to have_http_status(:ok)
      expect(page).to have_css(
        "h1",
        text: "Does the partner have a contrary interest in the proceedings?",
      )
    end
  end

  describe "PATCH /providers/:application_id/contrary_interest" do
    subject(:patch_request) { patch providers_legal_aid_application_contrary_interest_path(legal_aid_application), params: }

    before { patch_request }

    context "when form submitted with Save as draft button" do
      let(:params) { { applicant: { partner_has_contrary_interest: "" }, draft_button: "Save and come back later" } }

      it "redirects to the list of applications" do
        expect(response).to redirect_to providers_legal_aid_applications_path
      end
    end

    context "when yes chosen" do
      let(:params) { { applicant: { partner_has_contrary_interest: "true" } } }

      it "redirects to the check your answers page for the applicant" do
        expect(response).to redirect_to(providers_legal_aid_application_check_provider_answers_path(legal_aid_application))
      end
    end

    context "when no chosen" do
      let(:params) { { applicant: { partner_has_contrary_interest: "false" } } }

      it "redirects to the partners_details page" do
        expect(response).to redirect_to(providers_legal_aid_application_partners_details_path(legal_aid_application))
      end
    end

    context "when no answer chosen" do
      let(:params) { { applicant: { partner_has_contrary_interest: "" }, continue_button: "Save and continue" } }

      it "stays on the page if there is a validation error" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_error_message("Select yes if the partner has a contrary interest in the proceedings")
      end
    end

    def have_error_message(text)
      have_css(".govuk-error-summary__list > li", text:)
    end
  end
end
