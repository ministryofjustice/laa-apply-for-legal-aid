require "rails_helper"

module Providers
  module ProceedingMeritsTask
    RSpec.describe IsClientBiologicalParentController do
      let(:smtl) { create(:legal_framework_merits_task_list, :pb003_pb059, legal_aid_application:) }
      let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[pb003 pb059]) }
      let(:proceeding) { legal_aid_application.proceedings.find_by(ccms_code: "PB003") }
      let(:login) { login_as legal_aid_application.provider }

      before do
        allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
        login
      end

      describe "GET /providers/merits_task_list/:id/is_client_biological_parent" do
        subject(:get_request) { get providers_merits_task_list_is_client_biological_parent_path(proceeding) }

        it "renders successfully" do
          get_request
          expect(response).to have_http_status(:ok)
        end

        context "when the provider is not authenticated" do
          let(:login) { nil }

          before { get_request }

          it_behaves_like "a provider not authenticated"
        end
      end

      describe "PATCH /providers/merits_task_list/:id/is_client_biological_parent" do
        subject(:patch_request) do
          patch(
            providers_merits_task_list_is_client_biological_parent_path(proceeding),
            params: params.merge(submit_button),
          )
        end

        let(:params) do
          { proceeding: { relationship_to_child: } }
        end
        let(:submit_button) { {} }

        context "when the provider chooses yes" do
          let(:relationship_to_child) { "biological" }

          it "sets relationship_to_child to biological" do
            expect { patch_request }.to change { proceeding.reload.relationship_to_child }.to("biological")
          end

          it "updates the task list" do
            patch_request
            expect(legal_aid_application.legal_framework_merits_task_list).to have_completed_task(:PB003, :client_relationship_to_proceeding)
          end

          it "redirects to the next page" do
            patch_request
            expect(response).to have_http_status(:redirect)
          end
        end

        context "when provider chooses no" do
          let(:relationship_to_child) { "false" }

          it "does not change relationship_to_child" do
            expect { patch_request }.not_to change { proceeding.reload.relationship_to_child }
          end

          it "does not set the task to complete" do
            patch_request
            expect(legal_aid_application.legal_framework_merits_task_list).to have_not_started_task(:PB003, :client_relationship_to_proceeding)
          end

          it "redirects to next page" do
            patch_request
            expect(response).to have_http_status(:redirect)
          end
        end

        context "when provider makes no choice" do
          let(:relationship_to_child) { "" }

          it "does not change relationship_to_child" do
            expect { patch_request }.not_to change { proceeding.reload.relationship_to_child }
          end

          it "does not set the task to complete" do
            patch_request
            expect(legal_aid_application.legal_framework_merits_task_list).to have_not_started_task(:PB003, :client_relationship_to_proceeding)
          end

          it "re-renders the page with an error" do
            patch_request
            expect(response).to have_http_status(:ok)
            expect(response.body).to have_text("Select yes if your client is the biological parent of any children involved")
          end
        end

        context "when Form submitted using Save as draft button" do
          let(:submit_button) { { draft_button: "Save as draft" } }
          let(:relationship_to_child) { "biological" }

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

          it "updates the model" do
            patch_request
            proceeding.reload
            expect(proceeding.reload.relationship_to_child).to eq("biological")
          end
        end
      end
    end
  end
end
