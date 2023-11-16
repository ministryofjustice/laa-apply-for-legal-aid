require "rails_helper"

RSpec.describe Providers::CopyCase::InvitationsController do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:provider) { legal_aid_application.provider }
  let(:next_flow_step) { flow_forward_path }
  let(:login) { login_as provider }

  before { login }

  describe "GET /providers/applications/:legal_aid_application_id/copy_case_invitation" do
    subject(:get_request) do
      get providers_legal_aid_application_copy_case_invitation_path(legal_aid_application)
    end

    before { get_request }

    context "when the provider is not authenticated" do
      let(:login) { nil }

      it_behaves_like "a provider not authenticated"
    end

    it "renders page with expected heading" do
      expect(response).to have_http_status(:ok)
      expect(page).to have_css(
        "h1",
        text: "Do you want to copy an application to your current application?",
      )
    end
  end

  describe "PATCH /providers/:application_id/copy_case_invitation" do
    subject(:patch_request) { patch providers_legal_aid_application_copy_case_invitation_path(legal_aid_application), params: }

    before do
      allow(Setting).to receive(:linked_applications?).and_return(enable_linked_applications)
    end

    let(:enable_linked_applications) { true }

    context "when the provider is not authenticated" do
      let(:login) { nil }
      let(:params) { {} }

      before { patch_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when yes chosen" do
      let(:params) { { legal_aid_application: { copy_case: "true" } } }

      it "redirects to the copy case searches page" do
        patch_request
        expect(response).to redirect_to(providers_legal_aid_application_copy_case_search_path(legal_aid_application))
      end

      it "records the answer" do
        expect { patch_request }.to change { legal_aid_application.reload.copy_case }.from(nil).to(true)
      end
    end

    context "when no chosen" do
      let(:params) { { legal_aid_application: { copy_case: "false" } } }

      it "redirects to the proceeding types selection page" do
        patch_request
        expect(response).to redirect_to(providers_legal_aid_application_linking_case_invitation_path(legal_aid_application))
      end

      it "records the answer" do
        expect { patch_request }.to change { legal_aid_application.reload.copy_case }.from(nil).to(false)
      end
    end

    context "when no answer chosen" do
      let(:params) { { legal_aid_application: { copy_case: "" }, continue_button: "Save and continue" } }

      it "stays on the page and displays validation error" do
        patch_request
        expect(response).to have_http_status(:ok)
        expect(page).to have_error_message("Select yes if you want to copy an application")
      end
    end

    context "when form submitted using Save as draft button" do
      let(:params) { { legal_aid_application: { copy_case: "" }, draft_button: "irrelevant" } }

      it "redirects provider to provider's applications page" do
        patch_request
        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end

      it "sets the application as draft" do
        expect { patch_request }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
      end

      it "does not record the answer" do
        expect { patch_request }.not_to change { legal_aid_application.reload.copy_case }.from(nil)
      end
    end
  end
end
