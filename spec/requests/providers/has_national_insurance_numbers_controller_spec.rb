require "rails_helper"

RSpec.describe Providers::HasNationalInsuranceNumbersController do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:provider) { legal_aid_application.provider }
  let(:next_flow_step) { flow_forward_path }

  before { login_as provider }

  describe "GET /providers/applications/:legal_aid_application_id/has_national_insurance_number" do
    subject! do
      get providers_legal_aid_application_has_national_insurance_number_path(legal_aid_application)
    end

    it "renders page with expected heading" do
      expect(response).to have_http_status(:ok)
      expect(page).to have_css(
        "h1",
        text: "Does your client have a National Insurance number?",
      )
    end
  end

  describe "PATCH /providers/:application_id/has_national_insurance_number" do
    subject(:patch_has_nino) { patch providers_legal_aid_application_has_national_insurance_number_path(legal_aid_application), params: }

    before do
      patch_has_nino
    end

    context "when form submitted with Save as draft button" do
      let(:params) { { applicant: { has_national_insurance_number: "" }, draft_button: "Save and come back later" } }

      it "redirects to the list of applications" do
        expect(response).to redirect_to providers_legal_aid_applications_path
      end
    end

    context "when yes chosen and valid national insurance number provided" do
      let(:params) { { applicant: { has_national_insurance_number: "true", national_insurance_number: "JA 12 34 56 D" } } }

      it "redirects to the client_has_partner page" do
        expect(response).to redirect_to(providers_legal_aid_application_client_has_partner_path(legal_aid_application))
      end

      context "when the legal aid application is in overriding_dwp_result state" do
        let(:legal_aid_application) { create(:legal_aid_application, :overriding_dwp_result) }

        it "redirects to check provider answers page" do
          expect(response).to redirect_to(providers_legal_aid_application_check_provider_answers_path(legal_aid_application))
        end
      end
    end

    context "when no chosen" do
      let(:params) { { applicant: { has_national_insurance_number: "false" } } }

      it "redirects to the client_has_partner page" do
        expect(response).to redirect_to(providers_legal_aid_application_client_has_partner_path(legal_aid_application))
      end
    end

    context "when no answer chosen" do
      let(:params) { { applicant: { has_national_insurance_number: "" }, continue_button: "Save and continue" } }

      it "stays on the page if there is a validation error" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_error_message("Select yes if the client has a National Insurance number")
      end
    end
  end
end
