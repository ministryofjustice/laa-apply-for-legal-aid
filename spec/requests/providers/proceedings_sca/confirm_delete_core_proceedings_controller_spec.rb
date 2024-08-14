require "rails_helper"

RSpec.describe Providers::ProceedingsSCA::ConfirmDeleteCoreProceedingsController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[pb003 pb007], proceeding_count: 2) }
  let(:provider) { legal_aid_application.provider }
  let(:proceeding) { legal_aid_application.proceedings.find_by(ccms_code: "PB003") }

  describe "GET /providers/applications/:id/confirm_delete_core_proceeding" do
    subject(:get_request) { get providers_legal_aid_application_confirm_delete_core_proceeding_path(legal_aid_application, proceeding_id: proceeding.id) }

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
        expect(unescaped_response_body).to include("Are you sure you want to delete 'Child assessment order'?")
      end
    end
  end

  describe "DELETE /providers/applications/:id/confirm_delete_core_proceeding" do
    subject(:delete_request) { delete providers_legal_aid_application_confirm_delete_core_proceeding_path(legal_aid_application, proceeding_id: proceeding.id) }

    before do
      login_as provider
      delete_request
    end

    it "returns http success" do
      expect(response).to have_http_status(:redirect)
    end

    it "deletes the core proceedings and any related proceedings" do
      expect(legal_aid_application.proceedings.count).to eq 0
    end

    it "redirects to the providers_legal_aid_application_proceedings_types_path" do
      expect(response).to redirect_to providers_legal_aid_application_proceedings_types_path
    end

    context "when there are other proceedings left on the application" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[pb003 pb007 da001], proceeding_count: 2) }

      it "redirects to the providers_legal_aid_application_has_other_proceedings_path" do
        expect(response).to redirect_to providers_legal_aid_application_has_other_proceedings_path
      end

      it "does not delete non-sca proceedings" do
        expect(legal_aid_application.proceedings.count).to eq 1
        expect(legal_aid_application.proceedings.first.ccms_code).to eq "DA001"
      end

      it "sets the lead application" do
        expect(legal_aid_application.proceedings.find_by(ccms_code: "DA001").lead_proceeding).to be true
      end
    end
  end
end
