require "rails_helper"

RSpec.describe "does client use online banking requests", type: :request do
  let(:application) { create :legal_aid_application, :with_non_passported_state_machine, :applicant_details_checked, applicant: }
  let(:application_id) { application.id }
  let(:provider) { application.provider }
  let(:applicant) { create :applicant }

  describe "GET /providers/applications/:legal_aid_application_id/applicant" do
    subject(:request) { get "/providers/applications/#{application_id}/does-client-use-online-banking" }

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
        expect(unescaped_response_body).to include(I18n.t("providers.open_banking_consents.show.heading"))
      end

      context "when the application is in use_ccms state" do
        let(:application) { create :legal_aid_application, :with_non_passported_state_machine, :use_ccms }

        it "resets the state to provider_confirming_applicant_eligibility" do
          expect(application.reload.state).to eq "provider_confirming_applicant_eligibility"
        end
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/does-client-use-online-banking" do
    subject(:request) do
      patch(
        "/providers/applications/#{application_id}/does-client-use-online-banking",
        params: params.merge(submit_button),
      )
    end

    let(:provider_received_citizen_consent) { "true" }
    let(:submit_button) { {} }
    let(:params) do
      {
        legal_aid_application: {
          provider_received_citizen_consent:,
        },
      }
    end

    context "when provider is authenticated" do
      before { login_as provider }

      it "updates the application" do
        request
        expect(application.reload.provider_received_citizen_consent).to be(true)
      end

      context "when applicant is not employed after negative benefit check result" do
        context "when used_delegated_functions is true" do
          let(:application) do
            create :legal_aid_application,
                   :with_non_passported_state_machine,
                   :applicant_details_checked,
                   :with_proceedings,
                   :with_delegated_functions_on_proceedings,
                   explicit_proceedings: [:da004],
                   df_options: { DA004: [Time.zone.today, Time.zone.today] },
                   applicant:
          end

          let(:applicant) { create :applicant, :not_employed }

          it "redirects to the substantive application page" do
            request
            expect(response).to redirect_to(providers_legal_aid_application_substantive_application_path(application))
          end
        end

        context "when used_delegated_functions is false" do
          let(:application) do
            create :legal_aid_application, :with_non_passported_state_machine, :applicant_details_checked, applicant:
          end

          let(:applicant) { create :applicant, :not_employed }

          it "redirects to the client instructions page" do
            request
            expect(response).to redirect_to(providers_legal_aid_application_non_passported_client_instructions_path(application))
          end
        end
      end

      # TODO: no context defined here - what is a "positive benefit check result" value?
      context "when positive benefit check result" do
        it "redirects to the client instructions page" do
          request
          expect(response).to redirect_to(providers_legal_aid_application_non_passported_client_instructions_path(application))
        end

        context "when provider is bank statement upload enabled" do
          before do
            permission = build(:permission, :bank_statement_upload)
            application.provider.permissions << permission
          end

          context "when provider_received_citizen_consent is false" do
            let(:provider_received_citizen_consent) { "false" }

            it "redirects to the bank statement upload page" do
              request
              expect(response).to redirect_to(providers_legal_aid_application_bank_statements_path(application))
            end
          end

          context "when provider_received_citizen_consent is true" do
            let(:provider_received_citizen_consent) { "true" }

            it "redirects to the client instructions page" do
              request
              expect(response).to redirect_to(providers_legal_aid_application_non_passported_client_instructions_path(application))
            end
          end
        end

        context "when provider is not bank statement upload enabled" do
          before do
            application.provider.permissions.find_by(role: "application.non_passported.bank_statement_upload.*")&.destroy!
          end

          context "when provider_received_citizen_consent is false" do
            let(:provider_received_citizen_consent) { "false" }

            it "redirects to the use ccms page" do
              request
              expect(response).to redirect_to(providers_legal_aid_application_use_ccms_path(application))
            end
          end

          context "when provider_received_citizen_consent is true" do
            let(:provider_received_citizen_consent) { "true" }

            it "redirects to the client instructions page" do
              request
              expect(response).to redirect_to(providers_legal_aid_application_non_passported_client_instructions_path(application))
            end
          end
        end
      end

      context "when no option is chosen" do
        let(:params) { {} }

        it "shows an error" do
          request
          expect(unescaped_response_body).to include(I18n.t("activemodel.errors.models.legal_aid_application.attributes.open_banking_consents.providers.blank"))
        end
      end

      context "when form submitted using Save as draft button" do
        let(:submit_button) { { draft_button: "Save as draft" } }

        it "redirects provider to provider's applications page" do
          request
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end

        it "sets the application as draft" do
          request
          expect(application.reload).to be_draft
        end

        context "when no option is chosen" do
          let(:params) { {} }

          it "redirects provider to provider's applications page" do
            request
            expect(response).to redirect_to(providers_legal_aid_applications_path)
          end
        end
      end
    end
  end
end
