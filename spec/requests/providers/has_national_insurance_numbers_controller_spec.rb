require "rails_helper"

RSpec.describe Providers::HasNationalInsuranceNumbersController do
  let(:legal_aid_application) do
    create(:legal_aid_application)
  end

  let(:provider) { legal_aid_application.provider }
  let(:next_flow_step) { flow_forward_path }
  let(:mini_loop?) { false }

  before do
    login_as provider
  end

  describe "#pre_dwp_check?" do
    it { expect(described_class.new.pre_dwp_check?).to be true }
  end

  describe "GET /providers/applications/:legal_aid_application_id/has_national_insurance_number" do
    subject! do
      get providers_legal_aid_application_has_national_insurance_number_path(legal_aid_application)
    end

    it "renders page with expected heading" do
      expect(response).to have_http_status(:ok)
      expect(response).to render_template("providers/has_national_insurance_numbers/show")
      expect(response.body).to include("Does the client have a National Insurance number?")
    end
  end

  describe "PATCH /providers/:application_id/has_national_insurance_number" do
    subject! { patch providers_legal_aid_application_has_national_insurance_number_path(legal_aid_application), params: }

    context "when form submitted with Save as draft button" do
      let(:params) { { applicant: { has_national_insurance_number: "" }, draft_button: "Save and come back later" } }

      it "redirects to the list of applications" do
        expect(response).to redirect_to providers_legal_aid_applications_path
      end
    end

    context "when yes chosen and valid national insurance number provided" do
      let(:params) { { applicant: { has_national_insurance_number: "true", national_insurance_number: "JA 12 34 56 D" } } }

      it "redirects to the check your answers page for the applicant" do
        expect(response).to redirect_to(providers_legal_aid_application_check_provider_answers_path(legal_aid_application))
      end
    end

    context "when no chosen" do
      let(:params) { { applicant: { has_national_insurance_number: "false" } } }

      it "redirects to the check your answers page for the applicant" do
        expect(response).to redirect_to(providers_legal_aid_application_check_provider_answers_path(legal_aid_application))
      end
    end

    context "when no answer chosen" do
      let(:params) { { applicant: { has_national_insurance_number: "" }, continue_button: "Save and continue" } }

      it "stays on the page if there is a validation error" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_error_message("Select yes if the applicant has a National Insurance number")
      end
    end

    def have_error_message(text)
      have_css(".govuk-error-summary__list > li", text:)
    end
  end
end
