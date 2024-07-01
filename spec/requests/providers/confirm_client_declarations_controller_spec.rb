require "rails_helper"

RSpec.describe Providers::ConfirmClientDeclarationsController do
  let(:legal_aid_application) { create(:legal_aid_application) }

  before do
    freeze_time
    login
    request
  end

  describe "GET /providers/applications/:id/confirm_client_declaration" do
    subject(:request) do
      get providers_legal_aid_application_confirm_client_declaration_path(legal_aid_application)
    end

    context "when the provider is authenticated" do
      let(:login) { login_as legal_aid_application.provider }

      it "displays the declaration confirmation page", :aggregate_failures do
        expect(response).to have_http_status(:ok)
        expect(page).to have_content("Confirm the following")
      end
    end

    context "when the provider is not authenticated" do
      let(:login) { nil }

      it_behaves_like "a provider not authenticated"
    end
  end

  describe "PATCH /providers/applications/:id/confirm_client_declaration" do
    subject(:request) do
      patch providers_legal_aid_application_confirm_client_declaration_path(legal_aid_application),
            params: params.merge(submit_button)
    end

    let(:params) { { legal_aid_application: { client_declaration_confirmed: } } }
    let(:client_declaration_confirmed) { true }
    let(:submit_button) { { continue_button: "Continue" } }

    context "when the provider is authenticated" do
      let(:login) { login_as legal_aid_application.provider }

      context "when the provider confirms the declaration" do
        it "updates the application and redirects to the next page", :aggregate_failures do
          expect(legal_aid_application.reload.client_declaration_confirmed_at)
            .to eq Time.current
          expect(response).to have_http_status(:redirect)
        end
      end

      context "when the provider does not confirm the declaration" do
        let(:client_declaration_confirmed) { "" }

        it "doesn't update the application and displays an error", :aggregate_failures do
          expect(legal_aid_application.reload.client_declaration_confirmed_at)
            .to be_nil
          expect(page).to have_error_message("Confirm this information is correct and that you'll get a signed declaration")
        end
      end

      context "when the provider saves as draft" do
        let(:client_declaration_confirmed) { "" }
        let(:submit_button) { { draft_button: "Save as draft" } }

        it "sets the application as draft and redirects to the dashboard", :aggregate_failures do
          expect(legal_aid_application.reload).to be_draft
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end
      end
    end

    context "when the provider is not authenticated" do
      let(:login) { nil }
      let(:submit_button) { { continue_button: "Continue" } }

      it_behaves_like "a provider not authenticated"
    end
  end
end
