require "rails_helper"

module Providers
  module ApplicationMeritsTask
    RSpec.describe ClientCheckParentalAnswersController do
      let(:smtl) { create(:legal_framework_merits_task_list, :pb003_pb059_application, legal_aid_application:) }
      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_proceedings, :merits_parental_responsibilities, :with_sca_state_machine, explicit_proceedings: %i[pb003 pb059]) }
      let(:applicant) { legal_aid_application.applicant }
      let(:login) { login_as legal_aid_application.provider }

      before do
        allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
        login
      end

      describe "GET /providers/merits_task_list/:id/check_who_client_is" do
        before { get providers_legal_aid_application_client_check_parental_answer_path(legal_aid_application) }

        context "when the provider is not authenticated" do
          let(:login) { nil }

          it_behaves_like "a provider not authenticated"
        end

        context "when the provider is authenticated" do
          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end
        end
      end

      describe "PATCH providers/merits_task_list/:id/check_who_client_is" do
        subject(:patch_request) { patch providers_legal_aid_application_client_check_parental_answer_path(legal_aid_application), params: }

        context "when the provider is authenticated" do
          before do
            login
          end

          context "with Continue button pressed" do
            let(:params) do
              {
                continue_button: "Continue",
              }
            end

            it "redirects to next page" do
              patch_request
              expect(response).to have_http_status(:redirect)
            end
          end

          context "when Form submitted using Save as draft button" do
            let(:params) { { draft_button: "Save as draft" } }
            let(:relationship_to_children) { "false" }

            it "redirects provider to provider's applications page" do
              patch_request
              expect(response).to redirect_to(in_progress_providers_legal_aid_applications_path)
            end

            it "sets the application as draft" do
              expect { patch_request }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
            end

            it "does not set the task to complete" do
              patch_request
              expect(legal_aid_application.legal_framework_merits_task_list).to have_not_started_task(:application, :client_relationship_to_children)
            end
          end
        end
      end
    end
  end
end
