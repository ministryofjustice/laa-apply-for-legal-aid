require "rails_helper"

module Providers
  module ProceedingMeritsTask
    RSpec.describe SpecificIssueController do
      let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[da001 se004]) }
      let(:smtl) { create(:legal_framework_merits_task_list, :da001_and_se004, legal_aid_application:) }
      let(:proceeding) { legal_aid_application.proceedings.find_by(ccms_code: "DA001") }
      let(:proceeding_two) { legal_aid_application.proceedings.find_by(ccms_code: "SE004") }
      let(:provider) { legal_aid_application.provider }

      before { allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl) }

      describe "GET /providers/merits_task_list/:id/specific_issue" do
        subject(:get_specific_issue) { get providers_merits_task_list_specific_issue_path(proceeding) }

        context "when the provider is not authenticated" do
          before { get_specific_issue }

          it_behaves_like "a provider not authenticated"
        end

        context "when the provider is authenticated" do
          before do
            login_as provider
            get_specific_issue
          end

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end
        end
      end

      describe "PATCH providers/merits_task_list/:id/specific_issue" do
        subject(:patch_specific_issues) { patch providers_merits_task_list_specific_issue_path(proceeding_two), params: params.merge(submit_button) }

        let(:details) { Faker::Lorem.paragraph }
        let(:params) do
          {
            proceeding_merits_task_specific_issue: {
              details:,
            },
          }
        end

        context "when the provider is authenticated" do
          before do
            login_as provider
            patch_specific_issues
          end

          context "with Continue button pressed" do
            let(:submit_button) do
              {
                continue_button: "Continue",
              }
            end

            it "updates the record" do
              expect(proceeding_two.specific_issue.reload.details).to eq(details)
            end

            it "sets the task to complete" do
              expect(legal_aid_application.legal_framework_merits_task_list).to have_completed_task(:SE004, :specific_issue)
            end

            it "redirects to the next page" do
              expect(response).to have_http_status(:redirect)
            end
          end

          context "with Save as draft button pressed" do
            let(:submit_button) do
              {
                draft_button: "Save as draft",
              }
            end

            it "updates the record" do
              expect(proceeding_two.specific_issue.reload).to have_attributes(
                details:,
              )
            end

            it "redirects to provider applications home page" do
              expect(response).to redirect_to provider_draft_endpoint
            end
          end
        end
      end
    end
  end
end
