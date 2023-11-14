require "rails_helper"

RSpec.describe Providers::CopyCase::ConfirmationsController do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:source_application) { create(:legal_aid_application, :with_applicant, :with_proceedings, application_ref: "L-TVH-U0T") }
  let(:provider) { legal_aid_application.provider }
  let(:login) { login_as provider }

  before { login }

  describe "GET /providers/applications/:legal_aid_application_id/copy_case_confirmation" do
    subject(:get_request) do
      get providers_legal_aid_application_copy_case_confirmation_path(legal_aid_application)
    end

    context "when the provider is not authenticated" do
      let(:login) { nil }

      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        legal_aid_application.update!(copy_case_id: source_application.id)
      end

      it "renders page with expected headings" do
        get_request
        expect(response).to have_http_status(:ok)
        expect(page)
          .to have_css("h1", text: "Search result")
          .and have_css("h2", text: "Do you want to copy #{source_application.application_ref} to your application?")
      end
    end
  end

  describe "PATCH /providers/:application_id/copy_case_confirmation" do
    subject(:patch_request) { patch providers_legal_aid_application_copy_case_confirmation_path(legal_aid_application), params: }

    context "when the provider is not authenticated" do
      let(:login) { nil }
      let(:params) { {} }

      before { patch_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when yes chosen" do
      let(:params) { { legal_aid_application: { copy_case_id: source_application.id, copy_case_confirmation: "true" } } }

      it "redirects to the has national insurance number page" do
        patch_request
        expect(response).to redirect_to(providers_legal_aid_application_linking_case_confirmation_path(legal_aid_application))
      end

      it "copies proceedings from source application" do
        expect { patch_request }.to change { legal_aid_application.reload.proceedings.count }.from(0).to(1)
      end
    end

    context "when no chosen" do
      let(:params) { { legal_aid_application: { copy_case_id: source_application.id, copy_case_confirmation: "false" } } }

      it "redirects to the copy case invitation page" do
        patch_request
        expect(response).to redirect_to(providers_legal_aid_application_copy_case_invitation_path(legal_aid_application))
      end

      it "does not copy proceedings from source application" do
        expect { patch_request }.not_to change { legal_aid_application.reload.proceedings.count }.from(0)
      end
    end

    context "when no answer chosen" do
      let(:params) { { legal_aid_application: { copy_case_id: source_application.id } } }

      it "stays on the page and displays validation error" do
        patch_request
        expect(response).to have_http_status(:ok)
        expect(page).to have_error_message("Select yes if you want to copy the application")
      end
    end

    context "when form submitted using Save as draft button" do
      let(:params) { { legal_aid_application: { copy_case_id: source_application.id }, draft_button: "irrelevant" } }

      it "redirects provider to provider's applications page" do
        patch_request
        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end

      it "sets the application as draft" do
        expect { patch_request }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
      end

      it "does not copy proceedings from source application" do
        expect { patch_request }.not_to change { legal_aid_application.reload.proceedings.count }.from(0)
      end
    end
  end
end
