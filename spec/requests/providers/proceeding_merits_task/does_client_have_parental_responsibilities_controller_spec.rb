require "rails_helper"

module Providers
  module ProceedingMeritsTask
    RSpec.describe DoesClientHaveParentalResponsibilitiesController do
      let(:smtl) { create(:legal_framework_merits_task_list, :pb003_pb059, legal_aid_application:) }
      let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, :provider_entering_merits, :with_non_means_tested_state_machine, explicit_proceedings: %i[pb003 pb059]) }
      let(:proceeding) { legal_aid_application.proceedings.find_by(ccms_code: "PB003") }
      let(:login) { login_as legal_aid_application.provider }

      before do
        allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
        login
      end

      describe "GET /providers/merits_task_list/:id/does_client_have_parental_responsibility" do
        before { get providers_merits_task_list_does_client_have_parental_responsibility_path(proceeding) }

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

      describe "PATCH providers/merits_task_list/:id/does_client_have_parental_responsibility" do
        subject(:patch_request) { patch providers_merits_task_list_does_client_have_parental_responsibility_path(proceeding), params: params.merge(submit_button) }

        let(:params) do
          { proceeding: { relationship_to_child: } }
        end

        context "when the provider is authenticated" do
          before do
            login
          end

          context "with Continue button pressed" do
            let(:submit_button) do
              {
                continue_button: "Continue",
              }
            end

            context "when provider chooses 'yes, under a court order'" do
              let(:relationship_to_child) { "court_order" }

              it "sets relationship_to_child to court_order" do
                expect { patch_request }.to change { proceeding.reload.relationship_to_child }.to "court_order"
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

            context "when provider chooses 'yes, they have a parental responsibility agreement'" do
              let(:relationship_to_child) { "parental_responsibility_agreement" }

              it "sets relationship_to_child to court_order" do
                expect { patch_request }.to change { proceeding.reload.relationship_to_child }.to "parental_responsibility_agreement"
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

              it "redirects to the is_client_child_subject page" do
                patch_request
                expect(response).to redirect_to providers_merits_task_list_is_client_child_subject_path(proceeding)
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
                expect(response.body).to have_text("Select if your client has parental responsibility for any children involved")
              end
            end
          end

          context "when Form submitted using Save as draft button" do
            let(:submit_button) { { draft_button: "Save as draft" } }
            let(:relationship_to_child) { "court_order" }

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
              expect(proceeding.reload.relationship_to_child).to eq("court_order")
            end
          end
        end
      end
    end
  end
end
