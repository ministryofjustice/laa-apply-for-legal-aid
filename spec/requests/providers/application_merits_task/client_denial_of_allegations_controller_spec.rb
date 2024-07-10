require "rails_helper"

module Providers
  module ApplicationMeritsTask
    RSpec.describe ClientDenialOfAllegationsController do
      let(:legal_aid_application) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8) }
      let(:login_provider) { login_as legal_aid_application.provider }
      let(:smtl) { create(:legal_framework_merits_task_list, :da001_as_defendant, legal_aid_application:) }

      describe "GET /providers/applications/:legal_aid_application_id/client_denial_of_allegation" do
        subject(:client_denial) { get providers_legal_aid_application_client_denial_of_allegation_path(legal_aid_application) }

        before do
          login_provider
          client_denial
        end

        it "renders successfully" do
          expect(response).to have_http_status(:ok)
        end

        context "when not authenticated" do
          let(:login_provider) { nil }

          it_behaves_like "a provider not authenticated"
        end

        context "with an existing allegation" do
          let(:allegation) { create(:allegation, :with_data) }
          let(:legal_aid_application) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8, allegation:) }

          it "renders successfully" do
            expect(response).to have_http_status(:ok)
          end

          it "displays additional information" do
            expect(response.body).to include("extenuating circumstances")
          end
        end
      end

      describe "PATCH /providers/applications/:legal_aid_application_id/client_denial_of_allegation" do
        subject(:post_client_denial) do
          patch(
            providers_legal_aid_application_client_denial_of_allegation_path(legal_aid_application),
            params: params.merge(button_clicked),
          )
        end

        let(:denies_all) { true }
        let(:additional_information) { "" }
        let(:params) do
          {
            application_merits_task_allegation: {
              denies_all:,
              additional_information:,
            },
          }
        end
        let(:draft_button) { { draft_button: "Save as draft" } }
        let(:button_clicked) { {} }
        let(:allegation) { legal_aid_application.reload.allegation }

        before do
          allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
          login_provider
        end

        it "creates a new allegation with the values entered" do
          expect { post_client_denial }.to change(::ApplicationMeritsTask::Allegation, :count).by(1)
          expect(allegation.denies_all).to be_truthy
          expect(allegation.additional_information).to eq ""
        end

        it "sets the task to complete" do
          post_client_denial
          expect(legal_aid_application.legal_framework_merits_task_list).to have_completed_task(:application, :client_denial_of_allegation)
        end

        context "when all previous tasks are completed" do
          before do
            legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :latest_incident_details)
            legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :opponent_name)
            legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :opponent_mental_capacity)
            legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :domestic_abuse_summary)
            legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :statement_of_case)
          end

          it "redirects to the next page" do
            post_client_denial
            expect(response).to have_http_status(:redirect)
          end
        end

        context "when not authenticated" do
          let(:login_provider) { nil }

          before { post_client_denial }

          it_behaves_like "a provider not authenticated"
        end

        context "when incomplete" do
          let(:denies_all) { false }
          let(:additional_information) { "" }

          it "renders show" do
            post_client_denial
            expect(response).to have_http_status(:ok)
          end

          it "does not set the task to complete" do
            post_client_denial
            expect(legal_aid_application.legal_framework_merits_task_list).to have_not_started_task(:application, :client_denial_of_allegation)
          end
        end

        context "when save as draft selected" do
          let(:button_clicked) { draft_button }

          it "redirects to provider draft endpoint" do
            post_client_denial
            expect(response).to redirect_to provider_draft_endpoint
          end

          it "does not set the task to complete" do
            post_client_denial
            expect(legal_aid_application.legal_framework_merits_task_list).to have_not_started_task(:application, :client_denial_of_allegation)
          end
        end
      end
    end
  end
end
