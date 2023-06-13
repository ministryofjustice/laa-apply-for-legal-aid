require "rails_helper"

RSpec.describe Providers::Partners::EmployedController do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/partners/employed" do
    subject(:get_request) { get providers_legal_aid_application_partners_employed_index_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_request
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /providers/applications/:legal_aid_application_id/partners/employed" do
    subject(:post_request) { post providers_legal_aid_application_partners_employed_index_path(legal_aid_application), params: {} }

    context "when the provider is not authenticated" do
      before { post_request }

      it_behaves_like "a provider not authenticated"
    end

    context "with invalid params" do
      it "renders an error and does not update the record" do
        legal_aid_application = create(:legal_aid_application, :with_applicant_and_partner)
        login_as provider

        post_request

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("govuk-error-summary")
        expect(response.body).to include(I18n.t("activemodel.errors.models.partner.attributes.base.none_selected"))
        expect(legal_aid_application.reload.partner.employed).to be_nil
      end
    end

    context "with valid params" do
      it "updates the record" do
        legal_aid_application = create(:legal_aid_application, :with_applicant_and_partner)
        login_as legal_aid_application.provider

        post providers_legal_aid_application_partners_employed_index_path(legal_aid_application),
             params: { partner: { employed: "true" } }

        partner = legal_aid_application.reload.partner
        expect(partner).to be_employed
      end
    end

    context "when the application is ineligible for employment journey" do
      it "redirects to the use ccms employed page" do
        partner = create(:partner, self_employed: true)
        legal_aid_application = create(:legal_aid_application, partner:)
        provider = legal_aid_application.provider
        login_as provider

        post providers_legal_aid_application_partners_employed_index_path(legal_aid_application),
             params: { partner: { employed: "true" } }

        expect(response).to redirect_to(providers_legal_aid_application_use_ccms_employed_index_path(legal_aid_application))
      end
    end

    context "when the partner is eligible for employment journey" do
      it "redirects to the substantive applications page for applications that used delegated functions" do
        legal_aid_application = create(
          :legal_aid_application,
          :with_proceedings,
          :with_delegated_functions_on_proceedings,
          df_options: { DA001: [Date.yesterday, Date.current] },
        )
        provider = legal_aid_application.provider
        login_as provider

        post providers_legal_aid_application_partners_employed_index_path(legal_aid_application),
             params: { partner: { employed: "true" } }

        expect(response).to redirect_to(providers_legal_aid_application_substantive_application_path(legal_aid_application))
      end

      it "redirects to the open banking consent page for applications that have not used delegated functions" do
        legal_aid_application = create(:legal_aid_application)
        provider = legal_aid_application.provider
        login_as provider

        post providers_legal_aid_application_partners_employed_index_path(legal_aid_application),
             params: { partner: { employed: "true" } }

        expect(response).to redirect_to(providers_legal_aid_application_open_banking_consents_path(legal_aid_application))
      end
    end
  end
end
