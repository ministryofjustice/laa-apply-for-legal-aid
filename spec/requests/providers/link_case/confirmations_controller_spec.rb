require "rails_helper"

RSpec.describe Providers::LinkCase::ConfirmationsController do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:linkable_application) { create(:legal_aid_application, :with_applicant) }
  let(:linked_application) { create(:linked_application, lead_application_id: linkable_application.id, associated_application_id: legal_aid_application.id) }
  let(:login) { login_as legal_aid_application.provider }

  before { login }

  describe "GET /providers/applications/:legal_aid_application_id/link_case/confirmation" do
    subject(:get_request) { get providers_legal_aid_application_link_case_confirmation_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { get_request }

      let(:login) { nil }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        linked_application
        get_request
      end

      it "renders page with expected heading" do
        expect(response).to have_http_status(:ok)
        expect(page).to have_css("h1", text: "Link cases")
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/link_case/confirmation" do
    subject(:patch_request) { patch providers_legal_aid_application_link_case_confirmation_path(legal_aid_application), params: }

    before do
      linked_application
    end

    context "when form submitted with no params" do
      let(:params) { { linked_application: { link_type_code: "" }, continue_button: "Save and continue" } }

      it "stays on the page and shows a validation error" do
        patch_request
        expect(response).to have_http_status(:ok)
        expect(page).to have_error_message("Select an option")
      end
    end

    context "when form submitted with Save as draft button" do
      let(:params) { { linked_application: { link_type_code: "" }, draft_button: "Save and come back later" } }

      it "redirects to the list of applications" do
        patch_request
        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end
    end

    context "when family link selected" do
      let(:params) { { linked_application: { link_type_code: "FC_LEAD" }, continue_button: "Save and continue" } }

      it "updated linked application with a family link" do
        expect { patch_request }.to change { linked_application.reload.link_type_code }.from(nil).to("FC_LEAD")
      end

      it "redirects to address page" do
        patch_request
        expect(response).to redirect_to(providers_legal_aid_application_has_national_insurance_number_path(legal_aid_application))
      end
    end

    context "when legal link selected" do
      let(:params) { { linked_application: { link_type_code: "LEGAL" }, continue_button: "Save and continue" } }

      it "updated linked application with a legal link" do
        expect { patch_request }.to change { linked_application.reload.link_type_code }.from(nil).to("LEGAL")
      end

      it "redirects to NINO page" do
        patch_request
        expect(response).to redirect_to(providers_legal_aid_application_has_national_insurance_number_path(legal_aid_application))
      end
    end

    context "when no link selected" do
      let(:params) { { linked_application: { link_type_code: "false" }, continue_button: "Save and continue" } }

      it "destroys linked application" do
        expect { patch_request }.to change(LinkedApplication, :count).from(1).to(0)
      end

      it "redirects to linking case invitations page" do
        patch_request
        expect(response).to redirect_to(providers_legal_aid_application_link_case_invitation_path(legal_aid_application))
      end
    end
  end
end
