require "rails_helper"

module Providers
  module ProceedingMeritsTask
    RSpec.describe SpecificIssueController do
      let(:smtl) { create(:legal_framework_merits_task_list, :pb003_pb059, legal_aid_application:) }
      let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[pb003 pb059]) }
      let(:proceeding) { legal_aid_application.proceedings.find_by(ccms_code: "PB003") }
      let(:login) { login_as legal_aid_application.provider }

      before do
        allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
        login
      end

      describe "GET /providers/merits_task_list/:id/check_who_client_is" do
        before { get providers_merits_task_list_check_who_client_is_path(proceeding) }

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
        subject(:patch_request) { patch providers_merits_task_list_check_who_client_is_path(proceeding), params: }

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
            let(:relationship_to_child) { "false" }

            it "redirects provider to provider's applications page" do
              patch_request
              expect(response).to redirect_to(providers_legal_aid_applications_path)
            end

            it "sets the application as draft" do
              expect { patch_request }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
            end

            it "does not set the task to complete" do
              patch_request
              expect(legal_aid_application.legal_framework_merits_task_list).to have_not_started_task(:PB003, :client_relationship_to_proceeding)
            end
          end
        end
      end
    end
  end
end
