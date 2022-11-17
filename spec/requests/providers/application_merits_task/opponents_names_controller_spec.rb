require "rails_helper"

module Providers
  module ApplicationMeritsTask
    RSpec.describe OpponentsNamesController do
      let(:legal_aid_application) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8) }
      let(:login_provider) { login_as legal_aid_application.provider }
      let(:smtl) { create(:legal_framework_merits_task_list, legal_aid_application:) }
      let(:proceeding) { laa.proceedings.detect { |p| p.ccms_code == "SE014" } }

      describe "GET /providers/applications/:legal_aid_application_id/opponent_names" do
        subject(:get_name) { get providers_legal_aid_application_opponents_name_path(legal_aid_application) }

        before do
          allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
          login_provider
          get_name
        end

        it "renders successfully" do
          expect(response).to have_http_status(:ok)
        end

        context "when not authenticated" do
          let(:login_provider) { nil }

          it_behaves_like "a provider not authenticated"
        end

        context "with an existing opponent" do
          let(:opponent) { create(:opponent) }
          let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[da001 se014], opponent:) }

          it "renders successfully" do
            expect(response).to have_http_status(:ok)
          end

          it "displays opponent data" do
            expect(response.body).to include(html_compare(opponent.first_name))
            expect(response.body).to include(html_compare(opponent.last_name))
          end
        end
      end

      describe "PATCH /providers/applications/:legal_aid_application_id/opponent_name" do
        subject(:patch_name) do
          patch(
            providers_legal_aid_application_opponents_name_path(legal_aid_application),
            params: params.merge(button_clicked),
          )
        end

        let(:first_name) { Faker::Name.first_name }
        let(:last_name) { Faker::Name.last_name }
        let(:params) do
          {
            application_merits_task_opponent: {
              first_name:,
              last_name:,
            },
          }
        end
        let(:draft_button) { { draft_button: "Save as draft" } }
        let(:button_clicked) { {} }
        let(:opponent) { legal_aid_application.reload.opponent }

        before do
          allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
          login_provider
        end

        it "creates a new opponent with the values entered" do
          expect { patch_name }.to change(::ApplicationMeritsTask::Opponent, :count).by(1)
        end

        it "sets the task to complete" do
          patch_name
          expect(legal_aid_application.legal_framework_merits_task_list.serialized_data).to match(/name: :opponent_name\n\s+dependencies: \*\d+\n\s+state: :complete/)
        end

        context "when no other tasks are complete" do
          it "redirects to the next incomplete question" do
            patch_name
            expect(response).to redirect_to(providers_legal_aid_application_date_client_told_incident_path(legal_aid_application))
          end
        end

        context "when the first task is complete" do
          before { legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :latest_incident_details) }

          it "redirects to the next incomplete question" do
            patch_name
            expect(response).to redirect_to(providers_legal_aid_application_opponents_mental_capacity_path(legal_aid_application))
          end
        end

        context "when the all but one task is complete" do
          before do
            legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :latest_incident_details)
            legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :opponent_mental_capacity)
            legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :domestic_abuse_summary)
            legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :children_application)
          end

          it "redirects to the final question" do
            patch_name
            expect(response).to redirect_to(providers_legal_aid_application_statement_of_case_path(legal_aid_application))
          end
        end

        context "when not authenticated" do
          let(:login_provider) { nil }

          before { patch_name }

          it_behaves_like "a provider not authenticated"
        end

        context "when incomplete" do
          let(:last_name) { "" }

          it "renders show" do
            patch_name
            expect(response).to have_http_status(:ok)
          end

          it "does not set the task to complete" do
            patch_name
            expect(legal_aid_application.legal_framework_merits_task_list.serialized_data).to match(/name: :opponent_name\n\s+dependencies: \*\d+\n\s+state: :not_started/)
          end
        end

        context "when save as draft selected" do
          let(:button_clicked) { draft_button }

          it "redirects to provider draft endpoint" do
            patch_name
            expect(response).to redirect_to providers_legal_aid_applications_path
          end

          it "does not set the task to complete" do
            patch_name
            expect(legal_aid_application.legal_framework_merits_task_list.serialized_data).to match(/name: :opponent_name\n\s+dependencies: \*\d+\n\s+state: :not_started/)
          end
        end
      end
    end
  end
end
