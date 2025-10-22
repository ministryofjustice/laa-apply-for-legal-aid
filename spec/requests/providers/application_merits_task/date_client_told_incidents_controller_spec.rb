require "rails_helper"

module Providers
  module ApplicationMeritsTask
    RSpec.describe DateClientToldIncidentsController do
      let(:legal_aid_application) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8) }
      let(:login_provider) { login_as legal_aid_application.provider }
      let(:smtl) { create(:legal_framework_merits_task_list, legal_aid_application:) }

      describe "GET /providers/applications/:legal_aid_application_id/date_client_told_incident" do
        subject(:get_request) do
          get providers_legal_aid_application_date_client_told_incident_path(legal_aid_application)
        end

        before do
          login_provider
          get_request
        end

        it "renders successfully" do
          expect(response).to have_http_status(:ok)
        end

        context "when not authenticated" do
          let(:login_provider) { nil }

          it_behaves_like "a provider not authenticated"
        end

        context "with an existing incident" do
          let(:incident) { create(:incident, told_on: 3.days.ago.to_date, occurred_on: 5.days.ago.to_date) }
          let(:legal_aid_application) { create(:legal_aid_application, latest_incident: incident) }

          it "renders successfully" do
            expect(response).to have_http_status(:ok)
          end

          it "displays told_on incident data" do
            expect(page).to have_field("application_merits_task_incident[told_on]", with: incident.told_on.to_s(:date_picker))
          end

          it "displays occurred_on incident data" do
            expect(page).to have_field("application_merits_task_incident[occurred_on]", with: incident.occurred_on.to_s(:date_picker))
          end
        end
      end

      describe "PATCH /providers/applications/:legal_aid_application_id/date_client_told_incident" do
        subject(:patch_request) do
          patch(
            providers_legal_aid_application_date_client_told_incident_path(legal_aid_application),
            params: params.merge(button_clicked),
          )
        end

        let(:params) do
          {
            application_merits_task_incident: {
              told_on: told_on_string,
              occurred_on: occurred_on_string,
            },
          }
        end

        let(:told_on_string) { 3.days.ago.to_date.to_fs(:date_picker) }
        let(:occurred_on_string) { 5.days.ago.to_date.to_fs(:date_picker) }

        let(:draft_button) { { draft_button: "Save as draft" } }
        let(:button_clicked) { {} }
        let(:incident) { legal_aid_application.reload.latest_incident }

        before do
          allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
          login_provider
        end

        context "when provider not authenticated" do
          let(:login_provider) { nil }

          before { patch_request }

          it_behaves_like "a provider not authenticated"
        end

        context "when provider authenticated" do
          it "creates a new incident with the values entered" do
            expect { patch_request }.to change(::ApplicationMeritsTask::Incident, :count).from(0).to(1)

            expect(incident).to have_attributes(
              told_on: 3.days.ago.to_date,
              occurred_on: 5.days.ago.to_date,
            )
          end

          it "sets the task to complete" do
            expect(legal_aid_application.reload.legal_framework_merits_task_list).to have_not_started_task(:application, :latest_incident_details)
            patch_request
            expect(legal_aid_application.reload.legal_framework_merits_task_list).to have_completed_task(:application, :latest_incident_details)
          end

          it "redirects to the next page" do
            patch_request
            expect(response).to have_http_status(:redirect)
          end

          context "when params are blank or not valid" do
            let(:told_on_string) { "" }
            let(:occurred_on_string) { "" }

            it "renders show" do
              patch_request
              expect(response).to have_http_status(:ok)
            end

            it "does not set the task to complete" do
              expect(legal_aid_application.reload.legal_framework_merits_task_list).to have_not_started_task(:application, :latest_incident_details)
              patch_request
              expect(legal_aid_application.reload.legal_framework_merits_task_list).to have_not_started_task(:application, :latest_incident_details)
            end
          end

          context "when save as draft selected" do
            let(:button_clicked) { draft_button }

            it "redirects to provider draft endpoint" do
              patch_request
              expect(response).to have_http_status(:redirect)
            end

            it "does not set the task to complete" do
              expect(legal_aid_application.reload.legal_framework_merits_task_list).to have_not_started_task(:application, :latest_incident_details)
              patch_request
              expect(legal_aid_application.legal_framework_merits_task_list).to have_not_started_task(:application, :latest_incident_details)
            end
          end
        end
      end
    end
  end
end
