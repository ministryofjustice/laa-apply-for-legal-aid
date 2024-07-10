require "rails_helper"

module Providers
  module ProceedingMeritsTask
    RSpec.describe ProhibitedStepsController do
      let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[da001 se003]) }
      let(:login_provider) { login_as legal_aid_application.provider }
      let(:smtl) { create(:legal_framework_merits_task_list, :da001_as_defendant_se003, legal_aid_application:) }
      let(:proceeding) { legal_aid_application.proceedings.find_by(ccms_code: "DA001") }

      describe "GET /providers/applications/merits_task_list/:merits_task_list_id/opponents_application" do
        subject(:request) { get providers_merits_task_list_opponents_application_path(proceeding) }

        before do
          login_provider
          request
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

      describe "PATCH /providers/applications/merits_task_list/:merits_task_list_id/opponents_application" do
        subject(:request) do
          patch(
            providers_merits_task_list_opponents_application_path(proceeding),
            params: params.merge(button_clicked),
          )
        end

        let(:has_opponents_application) { "true" }
        let(:reason_for_applying) { "" }
        let(:params) do
          {
            proceeding_merits_task_opponents_application: {
              has_opponents_application:,
              reason_for_applying:,
            },
          }
        end
        let(:draft_button) { { draft_button: "Save as draft" } }
        let(:button_clicked) { {} }
        let(:opponents_application) { proceeding.reload.opponents_application }

        before do
          allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
          login_provider
        end

        it "creates a new opponents_application with the values entered" do
          expect { request }.to change(::ProceedingMeritsTask::OpponentsApplication, :count).by(1)
          expect(opponents_application.has_opponents_application).to be_truthy
          expect(opponents_application.reason_for_applying).to be_nil
        end

        it "sets the task to complete" do
          request
          expect(legal_aid_application.legal_framework_merits_task_list).to have_completed_task(:DA001, :opponents_application)
        end

        it "redirects to the next page" do
          request
          expect(response).to have_http_status(:redirect)
        end

        context "when not authenticated" do
          let(:login_provider) { nil }

          before { request }

          it_behaves_like "a provider not authenticated"
        end

        context "when incomplete" do
          let(:has_opponents_application) { "false" }
          let(:reason_for_applying) { "" }

          it "renders show" do
            request
            expect(response).to have_http_status(:ok)
          end

          it "does not set the task to complete" do
            request
            expect(legal_aid_application.legal_framework_merits_task_list).to have_not_started_task(:DA001, :opponents_application)
          end
        end

        context "when a previous record exists and when saving new parameters" do
          let(:opponents_application) { create(:opponents_application, :with_data, proceeding:) }
          let(:has_opponents_application) { "true" }
          let(:reason_for_applying) { "additional information about reason for applying" } # simulates changing yes/no but leaving textarea populated but hidden

          it "overwrites the values" do
            expect(opponents_application).to have_attributes(has_opponents_application: false, reason_for_applying: "additional information about reason for applying")
            request
            expect(opponents_application.reload).to have_attributes(has_opponents_application: true, reason_for_applying: nil)
          end
        end

        context "when save as draft selected" do
          let(:button_clicked) { draft_button }

          it "redirects to provider draft endpoint" do
            request
            expect(response).to redirect_to provider_draft_endpoint
          end

          it "does not set the task to complete" do
            request
            expect(legal_aid_application.legal_framework_merits_task_list).to have_not_started_task(:DA001, :opponents_application)
          end
        end
      end
    end
  end
end
