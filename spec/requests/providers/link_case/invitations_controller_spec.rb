require "rails_helper"

RSpec.describe Providers::LinkCase::InvitationsController do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:provider) { legal_aid_application.provider }

  before { login_as provider }

  describe "GET /providers/applications/:legal_aid_application_id/link_case/invitation" do
    it "renders page with expected heading" do
      get providers_legal_aid_application_link_case_invitation_path(legal_aid_application)
      expect(response).to have_http_status(:ok)
      expect(page).to have_css("h1", text: "Do you want to link an application to your application?")
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/link_case/invitation" do
    subject(:patch_request) { patch providers_legal_aid_application_link_case_invitation_path(legal_aid_application), params: }

    context "when form submitted with Save as draft button" do
      let(:params) { { legal_aid_application: { link_case: "" }, draft_button: "Save and come back later" } }

      it "redirects to the list of applications" do
        patch_request
        expect(response).to redirect_to providers_legal_aid_applications_path
      end
    end

    context "when no chosen" do
      let(:params) { { legal_aid_application: { link_case: "false" } } }

      context "without proceedings" do
        it "redirects to the proceeding_types page" do
          patch_request
          expect(response).to redirect_to(providers_legal_aid_application_proceedings_types_path(legal_aid_application))
        end
      end

      context "with proceedings" do
        before { create(:proceeding, :da001, legal_aid_application:) }

        it "redirects to the has_other_proceedings page" do
          patch_request
          expect(response).to redirect_to(providers_legal_aid_application_has_other_proceedings_path(legal_aid_application))
        end
      end

      it "updates link_case to false" do
        expect { patch_request }.to change { legal_aid_application.reload.link_case }.from(nil).to(false)
      end
    end

    context "when yes chosen" do
      let(:params) { { legal_aid_application: { link_case: "true" } } }

      it "redirects to link_case/search page" do
        patch_request
        expect(response).to redirect_to(providers_legal_aid_application_link_case_search_path(legal_aid_application))
      end

      it "updates link_case to true" do
        expect { patch_request }.to change { legal_aid_application.reload.link_case }.from(nil).to(true)
      end
    end

    context "when no answer chosen" do
      let(:params) { { legal_aid_application: { link_case: "" }, continue_button: "Save and continue" } }

      it "stays on the page if there is a validation error" do
        patch_request
        expect(response).to have_http_status(:ok)
        expect(page).to have_error_message("Select yes if you want to link an application to your application")
      end
    end
  end
end