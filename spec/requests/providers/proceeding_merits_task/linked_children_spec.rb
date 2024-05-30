require "rails_helper"

module Providers
  module ProceedingMeritsTask
    RSpec.describe LinkedChildrenController do
      let!(:legal_aid_application) do
        create(:legal_aid_application, :with_involved_children, :with_proceedings, explicit_proceedings: %i[da001 se014], set_lead_proceeding: :da001)
      end
      let(:proceeding) { legal_aid_application.proceedings.find_by(ccms_code: "SE014") }
      let(:involved_children_names) { legal_aid_application.involved_children.map(&:full_name) }
      let(:smtl) { create(:legal_framework_merits_task_list, legal_aid_application:) }
      let(:login) { login_as legal_aid_application.provider }

      before do
        allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
        login
      end

      describe "GET /providers/merits_task_list/:merits_task_list_id/linked_children" do
        subject(:get_request) { get providers_merits_task_list_linked_children_path(proceeding) }

        context "when the provider is not authenticated" do
          let(:login) { nil }

          before { get_request }

          it_behaves_like "a provider not authenticated"
        end

        context "when the provider is authenticated" do
          before { get_request }

          it "renders successfully" do
            expect(response).to have_http_status(:ok)
          end

          it "lists all involved children's names in the application" do
            expect(involved_children_names.all? { |name| response.body.include? html_compare(name) }).to be true
          end
        end
      end

      describe "PATCH /providers/merits_task_lists/:merits_task_list_id/linked_children" do
        subject(:patch_request) { patch providers_merits_task_list_linked_children_path(proceeding), params: }

        let(:params) do
          {
            proceeding_merits_task_proceeding_linked_child:
              { linked_children: legal_aid_application.involved_children.map(&:id) },
          }
        end

        before { legal_aid_application&.legal_framework_merits_task_list&.mark_as_complete!(:application, :children_application) }

        context "with all selected" do
          context "when the application has a Child arrangements order (residence) proceeding" do
            before { legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:SE014, :chances_of_success) }

            it "adds involved children to the proceeding" do
              expect { patch_request }.to change { proceeding.proceeding_linked_children.count }.by(3)
            end

            it "redirects to the next page" do
              patch_request
              expect(response).to have_http_status(:redirect)
            end
          end

          context "when the application contains a prohibited steps proceeding" do
            let(:legal_aid_application) { create(:legal_aid_application, :with_involved_children, :with_proceedings, explicit_proceedings: %i[da001 se003]) }
            let(:smtl) { create(:legal_framework_merits_task_list, :da001_as_defendant_se003, legal_aid_application:) }
            let(:proceeding) { legal_aid_application.proceedings.find_by(ccms_code: "SE003") }

            context "and all other steps are complete" do
              before do
                legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:SE003, :chances_of_success)
                legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:SE003, :attempts_to_settle)
              end

              it "redirects to the next page" do
                patch_request
                expect(response).to have_http_status(:redirect)
              end
            end
          end
        end

        context "with none selected" do
          let(:params) do
            {
              proceeding_merits_task_proceeding_linked_child:
                { linked_children: involved_children_names.map { |_k| "" } },
            }
          end

          it "does not add involved children to the proceeding" do
            expect { patch_request }.not_to change { proceeding.proceeding_linked_children.count }
          end
        end

        context "with some selected" do
          let(:params) do
            {
              proceeding_merits_task_proceeding_linked_child:
                { linked_children: legal_aid_application.involved_children.each_with_index.map { |child, index| index.zero? ? child.id : "" } },
            }
          end

          it "only adds the specified children to the proceeding" do
            proceeding_involved_children = proceeding.proceeding_linked_children
            expect { patch_request }.to change { proceeding_involved_children.count }.by(1)
          end
        end

        context "when a user has previously linked two children" do
          let(:update) do
            patch providers_merits_task_list_linked_children_path(proceeding), params: new_params
          end

          let(:first_child) { legal_aid_application.involved_children.first }
          let(:second_child) { legal_aid_application.involved_children.second }
          let(:third_child) { legal_aid_application.involved_children.third }
          let(:initial_array) { [second_child.id, third_child.id] }
          let(:linked_children_params) { [first_child.id, "", ""] }

          before do
            patch_request
          end

          context "when removing a record" do
            let(:new_params) do
              {
                proceeding_merits_task_proceeding_linked_child:
                  { linked_children: [first_child.id, "", ""] },
              }
            end

            it "deletes a record if it is deselected" do
              expect { update }.to change { proceeding.proceeding_linked_children.count }.by(-2)
            end
          end

          context "when record already exists" do
            it "makes no changes if already selected records are left selected" do
              expect { patch_request }.not_to change { proceeding.proceeding_linked_children.count }
            end
          end
        end

        context "when Form submitted using Save as draft button" do
          subject(:patch_request) do
            patch providers_merits_task_list_linked_children_path(proceeding), params: params.merge(submit_button)
          end

          let(:submit_button) { { draft_button: "Save as draft" } }

          it "redirects provider to provider's applications page" do
            patch_request
            expect(response).to redirect_to(providers_legal_aid_applications_path)
          end

          it "sets the application as draft" do
            expect { patch_request }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
          end

          it "does not set the task to complete" do
            patch_request
            expect(legal_aid_application.legal_framework_merits_task_list).to have_not_started_task(:SE014, :children_proceeding)
          end
        end
      end
    end
  end
end
