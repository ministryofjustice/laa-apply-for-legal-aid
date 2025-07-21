require "rails_helper"

RSpec.describe Providers::ApplicantEmployedController do
  describe "GET /providers/applications/:legal_aid_application_id/applicant_employed" do
    context "when the provider is not authenticated" do
      it "redirects the user to the root page" do
        legal_aid_application = create(:legal_aid_application)

        get providers_legal_aid_application_applicant_employed_index_path(legal_aid_application)

        expect(response).to redirect_to(root_path)
      end
    end

    context "when the provider is authenticated" do
      it "returns http success" do
        legal_aid_application = create(:legal_aid_application)
        login_as legal_aid_application.provider

        get providers_legal_aid_application_applicant_employed_index_path(legal_aid_application)

        expect(response).to have_http_status(:ok)
      end
    end

    context "when the application is in use_ccms state" do
      it "sets the state back to applicant details checked and removes the reason" do
        legal_aid_application = create(:legal_aid_application, :use_ccms_self_employed)
        login_as legal_aid_application.provider

        get providers_legal_aid_application_applicant_employed_index_path(legal_aid_application)

        expect(legal_aid_application.reload.state).to eq "applicant_details_checked"
        expect(legal_aid_application.ccms_reason).to be_nil
      end
    end
  end

  describe "POST /providers/applications/:legal_aid_application_id/applicant_employed" do
    context "when the provider is not authenticated" do
      it "redirects the user to the root page" do
        legal_aid_application = create(:legal_aid_application)

        post providers_legal_aid_application_applicant_employed_index_path(legal_aid_application), params: {}

        expect(response).to redirect_to(root_path)
      end
    end

    context "with invalid params" do
      it "renders an error and does not update the record" do
        applicant = create(:applicant, employed: nil)
        legal_aid_application = create(:legal_aid_application, applicant:)
        login_as legal_aid_application.provider

        post providers_legal_aid_application_applicant_employed_index_path(legal_aid_application),
             params: {}

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("govuk-error-summary")
        expect(response.body).to include(I18n.t("activemodel.errors.models.applicant.attributes.base.none_selected"))
        expect(legal_aid_application.reload.applicant.employed).to be_nil
      end
    end

    context "with valid params" do
      it "updates the record" do
        applicant = create(:applicant, employed: nil)
        legal_aid_application = create(:legal_aid_application, applicant:)
        login_as legal_aid_application.provider

        post providers_legal_aid_application_applicant_employed_index_path(legal_aid_application),
             params: { applicant: { employed: "true" } }

        applicant = legal_aid_application.reload.applicant
        expect(applicant).to be_employed
      end
    end

    context "when the application is ineligible for employment journey" do
      it "redirects to the use ccms employed page" do
        applicant = create(:applicant, self_employed: true)
        legal_aid_application = create(:legal_aid_application, applicant:)
        provider = legal_aid_application.provider
        login_as provider

        post providers_legal_aid_application_applicant_employed_index_path(legal_aid_application),
             params: { applicant: { employed: "true" } }

        expect(response).to redirect_to(providers_legal_aid_application_use_ccms_employment_index_path(legal_aid_application))
      end
    end

    context "when the applicant is eligible for employment journey" do
      it "redirects to the substantive applications page for applications that used delegated functions" do
        legal_aid_application = create(
          :legal_aid_application,
          :with_proceedings,
          :with_delegated_functions_on_proceedings,
          df_options: { DA001: [Date.yesterday, Date.current] },
        )
        provider = legal_aid_application.provider
        login_as provider

        post providers_legal_aid_application_applicant_employed_index_path(legal_aid_application),
             params: { applicant: { employed: "true" } }

        expect(response).to redirect_to(providers_legal_aid_application_substantive_application_path(legal_aid_application))
      end

      it "redirects to the open banking consent page for applications that have not used delegated functions" do
        legal_aid_application = create(:legal_aid_application)
        provider = legal_aid_application.provider
        login_as provider

        post providers_legal_aid_application_applicant_employed_index_path(legal_aid_application),
             params: { applicant: { employed: "true" } }

        expect(response).to redirect_to(providers_legal_aid_application_open_banking_consents_path(legal_aid_application))
      end
    end
  end
end
