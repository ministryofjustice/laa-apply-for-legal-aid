require "rails_helper"

module Providers
  module ProceedingMeritsTask
    RSpec.describe SuccessProspectsController do
      let!(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[da001 se014]) }
      let(:smtl) { create(:legal_framework_merits_task_list, legal_aid_application:) }
      let(:proceeding) { legal_aid_application.proceedings.find_by(ccms_code: "DA001") }
      let(:proceeding_two) { legal_aid_application.proceedings.find_by(ccms_code: "SE014") }
      let(:provider) { legal_aid_application.provider }

      before { allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl) }

      describe "GET /providers/merits_task_list/:id/success_prospects" do
        subject(:get_request) { get providers_merits_task_list_success_prospects_path(proceeding) }

        context "when the provider is not authenticated" do
          before { get_request }

          it_behaves_like "a provider not authenticated"
        end

        context "when the provider is authenticated" do
          before do
            login_as provider
            get_request
          end

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end
        end
      end

      describe "PATCH providers/merits_task_list/:id/success_prospects" do
        subject(:patch_request) { patch providers_merits_task_list_success_prospects_path(proceeding), params: params.merge(submit_button) }

        let(:success_prospect) { "marginal" }
        let(:success_prospect_details) { Faker::Lorem.paragraph }
        let(:params) do
          {
            proceeding_merits_task_chances_of_success: {
              success_prospect: success_prospect.to_s,
              success_prospect_details:,
            },
          }
        end

        context "when the provider is authenticated" do
          before do
            login_as provider
            patch_request
          end

          context "with Continue button pressed" do
            let(:submit_button) do
              {
                continue_button: "Continue",
              }
            end

            it "updates the record" do
              expect(proceeding.chances_of_success.reload.success_prospect).to eq(success_prospect)
              expect(proceeding.chances_of_success.reload.success_prospect_details).to eq(success_prospect_details)
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
              expect(proceeding.chances_of_success.reload.success_prospect).to eq(success_prospect)
              expect(proceeding.chances_of_success.reload.success_prospect_details).to eq(success_prospect_details)
            end

            it "redirects to provider applications home page" do
              expect(response).to redirect_to submitted_providers_legal_aid_applications_path
            end

            context "with nothing specified" do
              let(:success_prospect) { nil }
              let(:success_prospect_details) { nil }

              it "redirects to provider applications home page" do
                expect(response).to redirect_to submitted_providers_legal_aid_applications_path
              end
            end
          end
        end
      end
    end
  end
end
