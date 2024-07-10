require "rails_helper"

RSpec.describe Providers::Partners::EmployedController do
  let(:legal_aid_application) do
    create(
      :legal_aid_application,
      :with_non_passported_state_machine,
      :with_proceedings,
      :with_applicant_and_partner,
      :provider_confirming_applicant_eligibility,
    )
  end
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

    context "when the application is in use_ccms state" do
      let!(:legal_aid_application) do
        create(
          :legal_aid_application,
          :with_non_passported_state_machine,
          :with_proceedings,
          :with_applicant_and_partner,
          :use_ccms,
        )
      end

      before do
        login_as legal_aid_application.provider
        get_request
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "resets the state to assessing_partner_means" do
        expect(legal_aid_application.reload.state).to match("assessing_partner_means")
      end
    end
  end

  describe "POST /providers/applications/:legal_aid_application_id/partners/employed" do
    subject(:post_request) { post providers_legal_aid_application_partners_employed_index_path(legal_aid_application), params: }

    let(:params) { {} }
    let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_partner) }

    context "when the provider is not authenticated" do
      before { post_request }

      it_behaves_like "a provider not authenticated"
    end

    context "with invalid params" do
      it "renders an error and does not update the record" do
        login_as provider

        post_request

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("govuk-error-summary")
        expect(response.body).to include(I18n.t("activemodel.errors.models.partner.attributes.base.none_selected"))
        expect(legal_aid_application.reload.partner.employed).to be_nil
      end
    end

    context "with valid params" do
      let(:params) { { partner: { employed: "true" } } }

      it "updates the record" do
        login_as provider

        post_request

        partner = legal_aid_application.reload.partner
        expect(partner).to be_employed
      end
    end

    context "when the partner is eligible for employment journey" do
      it "redirects to the next step" do
        login_as provider

        post providers_legal_aid_application_partners_employed_index_path(legal_aid_application),
             params: { partner: { employed: "true" } }

        expect(response).to have_http_status(:redirect)
      end
    end

    context "when the partner is self employed" do
      it "redirects to the the next step" do
        login_as provider

        post providers_legal_aid_application_partners_employed_index_path(legal_aid_application),
             params: { partner: { self_employed: "true" } }

        expect(response).to have_http_status(:redirect)
      end
    end

    context "when the partner is in the armed forces" do
      it "redirects to the next step" do
        login_as provider

        post providers_legal_aid_application_partners_employed_index_path(legal_aid_application),
             params: { partner: { armed_forces: "true" } }

        expect(response).to have_http_status(:redirect)
      end
    end

    context "when the partner is employed but no nino was provided" do
      let(:params) { { partner: { employed: "true" } } }
      let(:legal_aid_application) { create(:legal_aid_application, :with_partner_no_nino) }

      before do
        login_as provider
        post_request
      end

      it "redirects to the full employment details page" do
        expect(response).to redirect_to(providers_legal_aid_application_partners_full_employment_details_path(legal_aid_application))
      end
    end
  end
end
