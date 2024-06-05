require "rails_helper"

module Providers
  module ApplicationMeritsTask
    RSpec.describe OpponentTypesController do
      let(:application) do
        create(:legal_aid_application,
               :with_multiple_proceedings_inc_section8)
      end
      let(:provider) { application.provider }
      let(:smtl) { create(:legal_framework_merits_task_list, legal_aid_application: application) }

      before do
        allow(LegalFramework::MeritsTasksService).to receive(:call).with(application).and_return(smtl)
        login_as provider
      end

      describe "show: GET /providers/applications/:legal_aid_application_id/opponent_type" do
        subject(:get_opponent_type) { get providers_legal_aid_application_opponent_type_path(application) }

        it "returns success" do
          get_opponent_type
          expect(response).to have_http_status(:ok)
        end

        it "displays the do you want to add more page" do
          get_opponent_type
          expect(response.body).to include("Is the opponent an individual or an organisation?")
        end
      end

      describe "update: PATCH /providers/applications/:legal_aid_application_id/opponent_type" do
        subject(:patch_opponent_type) { patch providers_legal_aid_application_opponent_type_path(application), params: params.merge(button_clicked) }

        let(:params) do
          {
            binary_choice_form: {
              is_individual: radio_button,
            },
            legal_aid_application_id: application.id,
          }
        end
        let(:draft_button) { { draft_button: "Save as draft" } }
        let(:button_clicked) { {} }

        context "when adding an individual" do
          let(:radio_button) { "true" }

          it "redirects to individual opponent" do
            patch_opponent_type
            expect(response).to have_http_status(:redirect)
          end

          it "does not set the task to complete" do
            patch_opponent_type
            expect(application.legal_framework_merits_task_list).to have_not_started_task(:application, :opponent_name)
          end
        end

        context "when adding an organisation" do
          let(:radio_button) { "false" }

          it "redirects to opponent existing organisation" do
            patch_opponent_type
            expect(response).to have_http_status(:redirect)
          end

          it "does not set the task to complete" do
            patch_opponent_type
            expect(application.legal_framework_merits_task_list).to have_not_started_task(:application, :opponent_name)
          end
        end

        context "with neither yes nor no selected" do
          let(:radio_button) { "" }

          it "re-renders the show page" do
            patch_opponent_type
            expect(response.body).to include("Is the opponent an individual or an organisation?")
          end

          it "displays the correct error message" do
            patch_opponent_type
            expect(unescaped_response_body).to include("There is a problem")
            expect(unescaped_response_body).to include("Select whether you want to add an individual or an organisation.")
          end

          it "does not set the task to complete" do
            patch_opponent_type
            expect(application.legal_framework_merits_task_list).to have_not_started_task(:application, :opponent_name)
          end
        end
      end
    end
  end
end
