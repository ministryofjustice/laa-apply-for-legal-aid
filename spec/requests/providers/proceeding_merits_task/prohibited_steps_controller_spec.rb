require "rails_helper"

module Providers
  module ProceedingMeritsTask
    RSpec.describe ProhibitedStepsController do
      let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[da001 se003]) }
      let(:login_provider) { login_as legal_aid_application.provider }
      let(:smtl) { create(:legal_framework_merits_task_list, :da001_as_defendant_se003, legal_aid_application:) }
      let(:proceeding) { legal_aid_application.proceedings.find_by(ccms_code: "SE003") }

      describe "GET /providers/applications/merits_task_list/:merits_task_list_id/prohibited_steps" do
        subject(:get_prohibited_steps) { get providers_merits_task_list_prohibited_steps_path(proceeding) }

        before do
          login_provider
          get_prohibited_steps
        end

        it "renders successfully" do
          expect(response).to have_http_status(:ok)
        end

        context "when not authenticated" do
          let(:login_provider) { nil }

          it_behaves_like "a provider not authenticated"
        end

        context "when authenticated as a different provider" do
          let(:login_provider) { login_as create(:provider) }

          it_behaves_like "an authenticated provider from a different firm"
        end
      end

      describe "PATCH /providers/applications/merits_task_list/:merits_task_list_id/prohibited_steps" do
        subject(:post_prohibited_steps) do
          patch(
            providers_merits_task_list_prohibited_steps_path(proceeding),
            params: params.merge(button_clicked),
          )
        end

        let(:uk_removal) { "true" }
        let(:details) { "" }
        let(:params) do
          {
            proceeding_merits_task_prohibited_steps: {
              uk_removal:,
              details:,
            },
          }
        end
        let(:draft_button) { { draft_button: "Save as draft" } }
        let(:button_clicked) { {} }
        let(:prohibited_steps) { proceeding.reload.prohibited_steps }

        before do
          allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
          login_provider
        end

        it "creates a new prohibited_steps with the values entered" do
          expect { post_prohibited_steps }.to change(::ProceedingMeritsTask::ProhibitedSteps, :count).by(1)
          expect(prohibited_steps.uk_removal).to be_truthy
          expect(prohibited_steps.details).to be_nil
        end

        it "sets the task to complete" do
          post_prohibited_steps
          expect(legal_aid_application.legal_framework_merits_task_list).to have_completed_task(:SE003, :prohibited_steps)
        end

        context "when all previous tasks are completed" do
          before do
            legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :latest_incident_details)
            legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :statement_of_case)
          end

          it "redirects to the next page" do
            post_prohibited_steps
            expect(response).to have_http_status(:redirect)
          end
        end

        context "when not authenticated" do
          let(:login_provider) { nil }

          before { post_prohibited_steps }

          it_behaves_like "a provider not authenticated"
        end

        context "when incomplete" do
          let(:uk_removal) { "false" }
          let(:details) { "" }

          it "renders show" do
            post_prohibited_steps
            expect(response).to have_http_status(:ok)
          end

          it "does not set the task to complete" do
            post_prohibited_steps
            expect(legal_aid_application.legal_framework_merits_task_list).to have_not_started_task(:SE003, :prohibited_steps)
          end
        end

        context "when a previous record exists and when saving new parameters" do
          let(:prohibited_steps) { create(:prohibited_steps, :with_data, proceeding:) }
          let(:uk_removal) { "true" }
          let(:details) { "additional data about steps" } # simulates changing yes/no but leaving textarea populated but hidden

          it "overwrites the values" do
            expect(prohibited_steps).to have_attributes(uk_removal: false, details: "additional data about steps")
            post_prohibited_steps
            expect(prohibited_steps.reload).to have_attributes(uk_removal: true, details: nil)
          end
        end

        context "when save as draft selected" do
          let(:button_clicked) { draft_button }

          it "redirects to provider draft endpoint" do
            post_prohibited_steps
            expect(response).to redirect_to provider_draft_endpoint
          end

          it "does not set the task to complete" do
            post_prohibited_steps
            expect(legal_aid_application.legal_framework_merits_task_list).to have_not_started_task(:SE003, :prohibited_steps)
          end
        end
      end
    end
  end
end
