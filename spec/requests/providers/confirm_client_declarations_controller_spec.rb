require "rails_helper"

RSpec.describe Providers::ConfirmClientDeclarationsController, type: :request do
  let(:application) { create(:legal_aid_application) }
  let(:provider) { application.provider }

  describe "GET /providers/applications/:id/confirm_client_declaration" do
    subject(:request) { get providers_legal_aid_application_confirm_client_declaration_path(application) }

    context "when the provider is not authenticated" do
      before { request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        request
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "displays the confirm client declaration page" do
        expect(unescaped_response_body).to include(I18n.t("providers.confirm_client_declarations.show.h1-heading"))
      end
    end
  end

  describe "PATCH /providers/applications/:id/confirm_client_declaration" do
    subject(:request) { patch providers_legal_aid_application_confirm_client_declaration_path(application), params: }

    let(:params) do
      {
        legal_aid_application: { client_declaration_confirmed: },
      }
    end
    let(:client_declaration_confirmed) { true }

    context "when the provider is authenticated" do
      before do
        login_as provider
        request
      end

      context "when form submitted with continue button" do
        let(:submit_button) do
          {
            continue_button: "Continue",
          }
        end

        context "when client_declaration_confirmed checkbox checked" do
          it "updates legal aid application client_declaration_confirmed" do
            expect(application.reload.client_declaration_confirmed_at >= 2.seconds.ago).to be true
          end
        end

        context "when client_declaration_confirmed checkbox unchecked" do
          let(:client_declaration_confirmed) { nil }

          it "does not update legal aid application client_declaration_confirmed" do
            expect(application.reload.client_declaration_confirmed_at).to be_nil
          end

          it "displays an error" do
            expect(unescaped_response_body).to include(I18n.t("activemodel.errors.models.legal_aid_application.attributes.client_declaration_confirmed.blank"))
          end
        end

        context "when form submitted using Save as draft button" do
          let(:params) { { draft_button: "Save as draft" } }

          it "redirect provider to provider's applications page" do
            request
            expect(response).to redirect_to(providers_legal_aid_applications_path)
          end

          it "sets the application as draft" do
            request
            expect(application.reload).to be_draft
          end
        end
      end
    end

    context "when unauthenticated" do
      before { request }

      it_behaves_like "a provider not authenticated"
    end
  end
end
