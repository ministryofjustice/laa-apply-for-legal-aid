require "rails_helper"

module Providers
  module ApplicationMeritsTask
    RSpec.describe HasOtherOpponentsController do
      let(:application) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8) }
      let(:provider) { application.provider }
      let(:opponent) { create(:opponent, legal_aid_application: application) }
      let(:smtl) { create(:legal_framework_merits_task_list, legal_aid_application: application) }

      before do
        allow(LegalFramework::MeritsTasksService).to receive(:call).with(application).and_return(smtl)
        login_as provider
      end

      describe "show: GET /providers/applications/:legal_aid_application_id/has_other_opponents" do
        subject(:get_has_other) { get providers_legal_aid_application_has_other_opponent_path(application) }

        before do
          create(:opponent, legal_aid_application: application)
          create(:opponent, :for_organisation, organisation_name: "Mid Beds Council", organisation_ccms_type_code: "LA", organisation_ccms_type_text: "Local Authority", legal_aid_application: application)
          create(:opponent, :for_individual, first_name: "John", last_name: "Doe", legal_aid_application: application)
        end

        it "returns success" do
          get_has_other
          expect(response).to have_http_status(:ok)
        end

        it "displays the opponent organisation and opponent individual" do
          get_has_other
          expect(response.body)
            .to include("Mid Beds Council")
            .and include("Local Authority")
            .and include("John Doe")
        end

        it "displays the do you want to add more page" do
          get_has_other
          expect(response.body).to include("You have added 3 opponents")
          expect(response.body).to include("Do you need to add another opponent?")
        end
      end

      describe "update: PATCH /providers/applications/:legal_aid_application_id/has_other_opponents" do
        subject(:patch_has_other) { patch providers_legal_aid_application_has_other_opponent_path(application), params: params.merge(button_clicked) }

        let(:params) do
          {
            binary_choice_form: {
              has_other_opponents: radio_button,
            },
            legal_aid_application_id: application.id,
          }
        end
        let(:draft_button) { { draft_button: "Save as draft" } }
        let(:button_clicked) { {} }

        context "when adding another opponent" do
          let(:radio_button) { "true" }

          it "redirects to opponent type" do
            patch_has_other
            expect(response).to have_http_status(:redirect)
          end

          it "does not set the task to complete" do
            patch_has_other
            expect(application.legal_framework_merits_task_list).to have_not_started_task(:application, :opponent_name)
          end
        end

        context "when not adding another opponent" do
          let(:radio_button) { "false" }

          before do
            application.legal_framework_merits_task_list.mark_as_complete!(:application, :latest_incident_details)
            application.legal_framework_merits_task_list.mark_as_complete!(:application, :children_application)
            application.legal_framework_merits_task_list.mark_as_complete!(:application, :opponent_mental_capacity)
            application.legal_framework_merits_task_list.mark_as_complete!(:application, :domestic_abuse_summary)
            application.legal_framework_merits_task_list.mark_as_complete!(:application, :statement_of_case)
          end

          it "redirects to why matter opposed page" do
            patch_has_other
            expect(response).to have_http_status(:redirect)
          end

          it "sets the task to complete" do
            patch_has_other
            expect(application.reload.legal_framework_merits_task_list).to have_completed_task(:application, :opponent_name)
          end
        end

        context "with neither yes nor no selected" do
          let(:radio_button) { "" }

          it "re-renders the show page" do
            patch_has_other
            expect(response.body).to include("Do you need to add another opponent?")
          end

          it "displays the correct error message" do
            patch_has_other
            expect(unescaped_response_body).to include("There is a problem")
            expect(unescaped_response_body).to include("Select yes if you need to add another opponent")
          end

          it "does not set the task to complete" do
            patch_has_other
            expect(application.legal_framework_merits_task_list).to have_not_started_task(:application, :opponent_name)
          end
        end
      end
    end
  end
end
