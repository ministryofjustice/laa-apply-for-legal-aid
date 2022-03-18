require "rails_helper"

module Providers
  module ProceedingMeritsTask
    RSpec.describe SuccessProspectsController, type: :request do
      let!(:legal_aid_application) { create :legal_aid_application, :with_proceedings }
      let(:proceeding) { legal_aid_application.proceedings.find_by(ccms_code: "DA001") }
      let(:proceeding_two) { legal_aid_application.proceedings.find_by(ccms_code: "SE014") }

      let(:provider) { legal_aid_application.provider }

      describe "GET /providers/merits_task_list/:id/success_prospects" do
        subject { get providers_merits_task_list_success_prospects_path(proceeding) }

        context "when the provider is not authenticated" do
          before { subject }
          it_behaves_like "a provider not authenticated"
        end

        context "when the provider is authenticated" do
          before do
            login_as provider
            subject
          end

          it "returns http success" do
            expect(response).to have_http_status(:ok)
          end
        end
      end

      describe "PATCH providers/merits_task_list/:id/success_prospects" do
        subject { patch providers_merits_task_list_success_prospects_path(proceeding), params: params.merge(submit_button) }
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
            subject
          end

          context "Continue button pressed" do
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
              expect(response).to redirect_to(providers_legal_aid_application_merits_task_list_path(legal_aid_application))
            end
          end

          context "Save as draft button pressed" do
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
              expect(response).to redirect_to providers_legal_aid_applications_path
            end

            context "nothing specified" do
              let(:success_prospect) { nil }
              let(:success_prospect_details) { nil }

              it "redirects to provider applications home page" do
                expect(response).to redirect_to providers_legal_aid_applications_path
              end
            end
          end
        end
      end
    end
  end
end
