require "rails_helper"

module Providers
  module ApplicationMeritsTask
    RSpec.describe OpponentsMentalCapacitiesController do
      let(:legal_aid_application) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8) }
      let(:login_provider) { login_as legal_aid_application.provider }
      let(:smtl) { create(:legal_framework_merits_task_list, legal_aid_application:) }
      let(:proceeding) { laa.proceedings.detect { |p| p.ccms_code == "SE014" } }

      describe "GET /providers/applications/:legal_aid_application_id/opponent_mental_capacity" do
        subject(:get_understanding) { get providers_legal_aid_application_opponents_mental_capacity_path(legal_aid_application) }

        before do
          allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
          login_provider
          get_understanding
        end

        it "renders successfully" do
          expect(response).to have_http_status(:ok)
        end

        context "when not authenticated" do
          let(:login_provider) { nil }

          it_behaves_like "a provider not authenticated"
        end

        context "with an existing parties_mental_capacity" do
          let(:parties_mental_capacity) { create(:parties_mental_capacity) }
          let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[da001 se014], parties_mental_capacity:) }

          it "renders successfully" do
            expect(response).to have_http_status(:ok)
          end

          it "displays parties_mental_capacity data" do
            expect(response.body).to include("Do all parties have the mental capacity to understand the terms of a court order?")
          end
        end
      end

      describe "PATCH /providers/applications/:legal_aid_application_id/opponent_mental_capacity" do
        subject(:patch_understanding) do
          patch(
            providers_legal_aid_application_opponents_mental_capacity_path(legal_aid_application),
            params: params.merge(button_clicked),
          )
        end

        let(:understands_terms_of_court_order) { "false" }
        let(:understands_terms_of_court_order_details) { "New understands terms of court order details" }
        let(:params) do
          {
            application_merits_task_parties_mental_capacity: {
              understands_terms_of_court_order:,
              understands_terms_of_court_order_details:,
            },
          }
        end
        let(:draft_button) { { draft_button: "Save as draft" } }
        let(:button_clicked) { {} }
        let(:parties_mental_capacity) { legal_aid_application.reload.parties_mental_capacity }

        before do
          allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
          login_provider
        end

        it "creates a new parties_mental_capacity with the values entered" do
          expect { patch_understanding }.to change(::ApplicationMeritsTask::PartiesMentalCapacity, :count).by(1)
        end

        it "sets the task to complete" do
          patch_understanding
          expect(legal_aid_application.legal_framework_merits_task_list.serialized_data).to match(/name: :opponent_mental_capacity\n\s+dependencies: \*\d+\n\s+state: :complete/)
        end

        context "when no other tasks are complete" do
          it "redirects to the next incomplete question" do
            patch_understanding
            expect(response).to have_http_status(:redirect)
          end
        end

        context "when the previous tasks are complete" do
          before do
            legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :latest_incident_details)
            legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :opponent_name)
            legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :domestic_abuse_summary)
          end

          it "redirects to the next incomplete question" do
            patch_understanding
            expect(response).to have_http_status(:redirect)
          end
        end

        context "when the all but one task is complete" do
          before do
            legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :latest_incident_details)
            legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :opponent_name)
            legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :domestic_abuse_summary)
            legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :children_application)
          end

          it "redirects to the final question" do
            patch_understanding
            expect(response).to have_http_status(:redirect)
          end
        end

        context "when not authenticated" do
          let(:login_provider) { nil }

          before { patch_understanding }

          it_behaves_like "a provider not authenticated"
        end

        context "when incomplete" do
          let(:understands_terms_of_court_order_details) { "" }

          it "renders show" do
            patch_understanding
            expect(response).to have_http_status(:ok)
          end

          it "does not set the task to complete" do
            patch_understanding
            expect(legal_aid_application.legal_framework_merits_task_list.serialized_data).to match(/name: :opponent_mental_capacity\n\s+dependencies: \*\d+\n\s+state: :not_started/)
          end
        end

        context "when save as draft selected" do
          let(:button_clicked) { draft_button }

          it "redirects to provider draft endpoint" do
            patch_understanding
            expect(response).to redirect_to in_progress_providers_legal_aid_applications_path
          end

          it "does not set the task to complete" do
            patch_understanding
            expect(legal_aid_application.legal_framework_merits_task_list.serialized_data).to match(/name: :opponent_mental_capacity\n\s+dependencies: \*\d+\n\s+state: :not_started/)
          end
        end
      end
    end
  end
end
