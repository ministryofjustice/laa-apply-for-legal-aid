require "rails_helper"

module Providers
  module ApplicationMeritsTask
    RSpec.describe HasOtherInvolvedChildrenController do
      subject(:get_request) { get providers_legal_aid_application_has_other_involved_children_path(application) }

      let(:application) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8) }
      let(:provider) { application.provider }
      let(:child1) { create(:involved_child, legal_aid_application: application) }
      let(:smtl) { create(:legal_framework_merits_task_list, legal_aid_application: application) }

      before do
        allow(LegalFramework::MeritsTasksService).to receive(:call).with(application).and_return(smtl)
        login_as provider
      end

      describe "show: GET /providers/applications/:legal_aid_application_id/has_other_involved_children" do
        it "returns success" do
          get_request
          expect(response).to have_http_status(:ok)
        end

        it "displays the do you want to add more page" do
          child1
          get_request
          expect(response.body).to include("You have added 1 child")
          expect(response.body).to include("Do you need to add another child?")
        end
      end

      describe "update: PATCH /providers/applications/:legal_aid_application_id/has_other_involved_children" do
        subject(:patch_request) { patch providers_legal_aid_application_has_other_involved_children_path(application), params: params.merge(button_clicked) }

        let(:params) do
          {
            binary_choice_form: {
              has_other_involved_child: radio_button,
            },
            legal_aid_application_id: application.id,
          }
        end
        let(:draft_button) { { draft_button: "Save as draft" } }
        let(:button_clicked) { {} }

        context "when adding more children" do
          let(:radio_button) { "true" }

          it "redirects to new involved child" do
            patch_request
            expect(response).to have_http_status(:redirect)
          end

          it "does not set the task to complete" do
            patch_request
            expect(application.legal_framework_merits_task_list).to have_not_started_task(:application, :children_application)
          end
        end

        context "when not adding more children" do
          let(:radio_button) { "false" }

          before do
            application.legal_framework_merits_task_list.mark_as_complete!(:application, :latest_incident_details)
            application.legal_framework_merits_task_list.mark_as_complete!(:application, :opponent_name)
            application.legal_framework_merits_task_list.mark_as_complete!(:application, :opponent_mental_capacity)
            application.legal_framework_merits_task_list.mark_as_complete!(:application, :domestic_abuse_summary)
            application.legal_framework_merits_task_list.mark_as_complete!(:application, :statement_of_case)
          end

          it "redirects to why matter opposed page" do
            patch_request
            expect(response).to have_http_status(:redirect)
          end

          it "sets the task to complete" do
            patch_request
            expect(application.reload.legal_framework_merits_task_list).to have_completed_task(:application, :children_application)
          end
        end

        context "with neither yes nor no selected" do
          let(:radio_button) { "" }

          it "re-renders the show page" do
            patch_request
            expect(response.body).to include("Do you need to add another child?")
          end

          it "displays the correct error message" do
            patch_request
            expect(unescaped_response_body).to include("There is a problem")
            expect(unescaped_response_body).to include("Select yes if you need to add another child")
          end

          it "does not set the task to complete" do
            patch_request
            expect(application.legal_framework_merits_task_list).to have_not_started_task(:application, :children_application)
          end
        end
      end

      describe "DELETE /providers/:application_id/has_other_involved_children" do
        subject(:delete_request) { delete providers_legal_aid_application_has_other_involved_children_path(application), params: }

        before { create_list(:involved_child, 2, legal_aid_application: application) }

        let(:involved_child_one) { application.involved_children.first }

        let(:params) do
          {
            involved_child_id: involved_child_one.id,
          }
        end

        context "when an involved child is removed" do
          let(:involved_child_two) { application.involved_children.second }

          it "removes one involved_child" do
            expect { delete_request }.to change { application.involved_children.count }.by(-1)
          end

          it "leaves the correct number of remaining involved_children" do
            delete_request
            expect(application.involved_children.count).to eq 1
          end

          it "displays the singular number of involved children remaining" do
            delete_request
            expect(response.body).to include("You have added 1 child")
          end

          it "sets the correct flash message" do
            delete_request
            expect(response.body).to have_css(".moj-alert__content", text: "You removed #{involved_child_one.full_name} as an involved child")
          end

          context "when removing the only involved child on the application" do
            before { application.involved_children.second.destroy! }

            it "removes one involved_child" do
              expect { delete_request }.to change { application.involved_children.count }.by(-1)
            end

            it "leaves the correct number of remaining involved children" do
              delete_request
              expect(application.reload.involved_children.count).to eq 0
            end

            it "redirects to new involved child page" do
              delete_request
              expect(response).to redirect_to(new_providers_legal_aid_application_involved_child_path(application))
            end
          end
        end
      end
    end
  end
end
