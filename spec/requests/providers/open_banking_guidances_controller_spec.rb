require "rails_helper"

RSpec.describe Providers::OpenBankingGuidancesController, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application, :with_non_passported_state_machine, :provider_confirming_applicant_eligibility) }
  let(:id) { legal_aid_application.id }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:id/open_banking_guidance" do
    subject(:request) { get providers_legal_aid_application_open_banking_guidance_path(legal_aid_application) }

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

      it "displays the correct page" do
        expect(unescaped_response_body).to include(I18n.t("providers.open_banking_guidances.show.heading_h1"))
      end

      context "when the application is in use_ccms state" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_non_passported_state_machine, :use_ccms) }

        it "resets the state to provider_confirming_applicant_eligibility" do
          expect(legal_aid_application.reload.state).to eq "provider_confirming_applicant_eligibility"
        end
      end
    end
  end

  describe "PATCH /providers/applications/:id/open_banking_guidance" do
    subject(:request) { patch providers_legal_aid_application_open_banking_guidance_path(legal_aid_application), params: }

    let(:params) do
      {
        binary_choice_form: {
          can_client_use_truelayer:,
        },
      }
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      context "when invalid params and nothing is selected" do
        before { request }

        let(:params) { {} }

        it "returns http_success" do
          expect(response).to have_http_status(:ok)
        end

        it "the response includes the error message" do
          expect(response.body).to include(I18n.t("providers.can_client_use_truelayers.show.error"))
        end
      end

      context "when yes is selected" do
        before { request }

        let(:can_client_use_truelayer) { "true" }

        it "redirects to the enter client email address page" do
          expect(response).to redirect_to providers_legal_aid_application_email_address_path
        end
      end

      context "when no is selected" do
        let(:can_client_use_truelayer) { "false" }

        context "when provider has bank upload permissions" do
          before do
            permission = build(:permission, :bank_statement_upload)
            legal_aid_application.provider.permissions << permission
            request
          end

          it "redirects to the bank statement upload page" do
            request
            expect(response).to redirect_to providers_legal_aid_application_bank_statements_path
          end
        end

        context "when provider does not have bank upload permissions" do
          before do
            legal_aid_application.provider.permissions.find_by(role: "application.non_passported.bank_statement_upload.*")&.destroy!
          end

          it "redirects to the use ccms page" do
            request
            expect(response).to redirect_to providers_legal_aid_application_use_ccms_path
          end
        end
      end
    end
  end
end
