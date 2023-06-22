require "rails_helper"

RSpec.describe Providers::Partners::UseCCMSEmploymentController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_self_employed_partner) }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:id/partners/use_ccms_employment" do
    subject(:get_request) { get providers_legal_aid_application_partners_use_ccms_employment_index_path(legal_aid_application) }

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

      it "shows text to use CCMS" do
        expect(response.body).to include(I18n.t("shared.use_ccms.title_html"))
      end

      context "and the partner is self employed" do
        it "sets state to use_ccms and reason to partner_self_employed" do
          expect(legal_aid_application.reload.state).to eq "use_ccms"
          expect(legal_aid_application.ccms_reason).to eq "partner_self_employed"
        end
      end

      context "and the partner is a member of the armed forces" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_partner_in_armed_forces) }

        it "sets state to use_ccms and reason to partner_armed_forces" do
          expect(legal_aid_application.reload.state).to eq "use_ccms"
          expect(legal_aid_application.ccms_reason).to eq "partner_armed_forces"
        end
      end
    end
  end
end
