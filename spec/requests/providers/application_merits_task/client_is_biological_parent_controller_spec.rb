require "rails_helper"

module Providers
  module ApplicationMeritsTask
    RSpec.describe ClientIsBiologicalParentController do
      let(:smtl) { create(:legal_framework_merits_task_list, :pb003_pb059_application, legal_aid_application:) }
      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_proceedings, :provider_entering_merits, :with_sca_state_machine, explicit_proceedings: %i[pb003 pb059]) }
      let(:applicant) { legal_aid_application.applicant }
      let(:login) { login_as legal_aid_application.provider }

      before do
        allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
        login
      end

      describe "GET /providers/merits_task_list/:id/is_client_biological_parent" do
        subject(:get_request) { get providers_legal_aid_application_client_is_biological_parent_path(legal_aid_application) }

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
            providers_legal_aid_application_client_is_biological_parent_path(legal_aid_application),
            params: params.merge(submit_button),
          )
        end

        let(:params) do
          { applicant: { relationship_to_children: } }
        end
        let(:submit_button) { {} }

        context "when the provider chooses yes" do
          let(:relationship_to_children) { "biological" }

          it "sets relationship_to_children to biological" do
            expect { patch_request }.to change { applicant.reload.relationship_to_children }.to("biological")
          end

          it "updates the task list" do
            patch_request
            expect(legal_aid_application.legal_framework_merits_task_list).to have_completed_task(:application, :client_relationship_to_children)
          end

          it "redirects to the next page" do
            patch_request
            expect(response).to have_http_status(:redirect)
          end
        end

        context "when provider chooses no" do
          let(:relationship_to_children) { "false" }

          it "does not change relationship_to_children" do
            expect { patch_request }.not_to change { applicant.reload.relationship_to_children }
          end

          it "does not set the task to complete" do
            patch_request
            expect(legal_aid_application.legal_framework_merits_task_list).to have_not_started_task(:application, :client_relationship_to_children)
          end

          it "redirects to parental responsibility question page" do
            patch_request
            expect(response).to redirect_to providers_legal_aid_application_client_has_parental_responsibility_path(legal_aid_application)
          end
        end

        context "when provider makes no choice" do
          let(:relationship_to_children) { "" }

          it "does not change relationship_to_children" do
            expect { patch_request }.not_to change { applicant.reload.relationship_to_children }
          end

          it "does not set the task to complete" do
            patch_request
            expect(legal_aid_application.legal_framework_merits_task_list).to have_not_started_task(:application, :client_relationship_to_children)
          end

          it "re-renders the page with an error" do
            patch_request
            expect(response).to have_http_status(:ok)
            expect(response.body).to have_text("Select yes if your client is the biological parent of any children involved")
          end
        end

        context "when Form submitted using Save as draft button" do
          let(:submit_button) { { draft_button: "Save as draft" } }
          let(:relationship_to_children) { "biological" }

          it "redirects provider to provider's applications page" do
            patch_request
            expect(response).to redirect_to(submitted_providers_legal_aid_applications_path)
          end

          it "sets the application as draft" do
            expect { patch_request }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
          end

          it "does not set the task to complete" do
            patch_request
            expect(legal_aid_application.legal_framework_merits_task_list).to have_not_started_task(:application, :client_relationship_to_children)
          end

          it "updates the model" do
            patch_request
            legal_aid_application.reload
            expect(applicant.reload.relationship_to_children).to eq("biological")
          end
        end
      end
    end
  end
end
