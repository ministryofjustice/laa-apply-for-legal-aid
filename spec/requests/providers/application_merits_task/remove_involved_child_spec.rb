require "rails_helper"

module Providers
  module ApplicationMeritsTask
    RSpec.describe RemoveInvolvedChildController do
      let(:application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[da001 se003]) }
      let(:provider) { application.provider }
      let!(:child) { create(:involved_child, legal_aid_application: application) }

      before do
        create(:legal_framework_merits_task_list, :da001_as_defendant_se003, legal_aid_application: application)
        application.legal_framework_merits_task_list.mark_as_complete!(:application, :children_application)
        login_as provider
      end

      describe "show GET /providers/applications/:legal_aid_application_id/remove_involved_child/:id" do
        subject(:get_request) { get providers_legal_aid_application_remove_involved_child_path(application, child) }

        it "displays the childs details" do
          get_request
          expect(response.body).to include(html_compare(child.full_name))
        end
      end

      describe "update PATCH /providers/applications/:legal_aid_application_id/remove_involved_child/:id" do
        subject(:patch_request) { patch providers_legal_aid_application_remove_involved_child_path(application, child), params: }

        let(:params) do
          {
            binary_choice_form: {
              remove_involved_child: radio_button,
            },
            legal_aid_application_id: application.id,
          }
        end

        context "when child is removed" do
          let(:radio_button) { "true" }

          it "deletes the involved child record" do
            expect { patch_request }.to change { application.involved_children.count }.by(-1)
          end

          it "redirects along the flow" do
            patch_request
            expect(response).to have_http_status(:redirect)
          end

          context "and no children remain" do
            it "sets the children_application task to not_started" do
              patch_request
              expect(application.reload.legal_framework_merits_task_list).to have_not_started_task(:application, :children_application)
            end
          end

          context "and children remain" do
            before { create(:involved_child, legal_aid_application: application) }

            it "leaves the children_application task as completed" do
              patch_request
              expect(application.reload.legal_framework_merits_task_list).to have_completed_task(:application, :children_application)
            end
          end
        end

        context "when child is not removed" do
          let(:radio_button) { "false" }

          it "does not delete a record" do
            expect { patch_request }.not_to change { application.involved_children.count }
          end

          it "redirects along the flow" do
            patch_request
            expect(response).to have_http_status(:redirect)
          end
        end

        context "with neither yes nor no specified" do
          let(:radio_button) { "" }

          it "shows the correct error message" do
            patch_request
            expect(response).to have_http_status(:ok)
            expect(unescaped_response_body).to include(I18n.t("providers.application_merits_task.remove_involved_child.show.error", name: child.full_name))
          end

          it "does not delete a record" do
            expect { patch_request }.not_to change { application.involved_children.count }
          end
        end
      end
    end
  end
end
