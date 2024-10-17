require "rails_helper"

module Providers
  module ProceedingMeritsTask
    RSpec.describe ChancesOfSuccessController do
      let(:smtl) { create(:legal_framework_merits_task_list, :da001_as_defendant_se003, legal_aid_application:) }
      let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[da001 se003]) }
      let(:proceeding) { legal_aid_application.proceedings.find_by(ccms_code: "DA001") }
      let(:login) { login_as legal_aid_application.provider }

      before do
        allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
        login
      end

      describe "GET /providers/merits_task_list/:id/chances_of_success" do
        subject(:get_request) { get providers_merits_task_list_chances_of_success_index_path(proceeding) }

        it "renders successfully" do
          get_request
          expect(response).to have_http_status(:ok)
        end

        context "when the provider is not authenticated" do
          let(:login) { nil }

          before { get_request }

          it_behaves_like "a provider not authenticated"
        end
      end

      describe "POST /providers/merits_task_list/:id/chances_of_success" do
        subject(:post_request) do
          post(
            providers_merits_task_list_chances_of_success_index_path(proceeding),
            params: params.merge(submit_button),
          )
        end

        let(:success_prospect) { :poor }
        let!(:chances_of_success) do
          create(:chances_of_success, success_prospect:, success_prospect_details: "details",
                                      proceeding:)
        end
        let(:success_likely) { "true" }
        let(:params) do
          { proceeding_merits_task_chances_of_success: { success_likely: } }
        end
        let(:submit_button) { {} }

        it "sets chances_of_success to true" do
          expect { post_request }.to change { chances_of_success.reload.success_likely }.to(true)
        end

        it "sets success_prospect to likely" do
          expect { post_request }.to change { chances_of_success.reload.success_prospect }.to("likely")
        end

        it "sets success_prospect_details to nil" do
          expect { post_request }.to change { chances_of_success.reload.success_prospect_details }.to(nil)
        end

        it "redirects to the next page" do
          post_request
          expect(response).to have_http_status(:redirect)
        end

        it "updates the task list" do
          post_request
          expect(legal_aid_application.legal_framework_merits_task_list.serialized_data).to match(/name: :chances_of_success\n\s+dependencies: \*\d+\n\s+state: :complete/)
        end

        context "when false is selected" do
          let(:success_likely) { "false" }

          it "sets chances_of_success to false" do
            expect { post_request }.to change { chances_of_success.reload.success_likely }.to(false)
          end

          it "does not change success_prospect" do
            expect { post_request }.not_to change { chances_of_success.reload.success_prospect }
          end

          it "does not change success_prospect_details" do
            expect { post_request }.not_to change { chances_of_success.reload.success_prospect_details }
          end

          it "does not set the task to complete" do
            post_request
            expect(legal_aid_application.legal_framework_merits_task_list).to have_not_started_task(:DA001, :chances_of_success)
          end

          it "redirects to next page" do
            post_request
            expect(response).to have_http_status(:redirect)
          end

          context "when success_prospect was :likely" do
            let(:success_prospect) { :likely }

            it "sets success_prospect to nil" do
              expect { post_request }.to change { chances_of_success.reload.success_prospect }.to(nil)
            end
          end
        end

        context "when user has come from the check_merits_answer page" do
          let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, :checking_merits_answers, explicit_proceedings: %i[da001 se003]) }

          it "redirects back to the answers page" do
            post_request
            expect(response).to redirect_to(providers_legal_aid_application_check_merits_answers_path(legal_aid_application))
          end

          context "when the user updates to say no" do
            let(:success_likely) { "false" }

            it "redirects back to the answers page" do
              post_request
              expect(response).to redirect_to(providers_merits_task_list_success_prospects_path(proceeding))
            end
          end
        end

        context "when nothing is selected" do
          let(:params) { {} }

          it "renders successfully" do
            post_request
            expect(response).to have_http_status(:ok)
          end

          it "displays error" do
            post_request
            expect(response.body).to include("govuk-error-summary")
          end

          it "the response includes the error message" do
            post_request
            expect(response.body).to include(I18n.t("activemodel.errors.models.proceeding_merits_task/chances_of_success.attributes.success_likely.blank"))
          end
        end

        context "when Form submitted using Save as draft button" do
          let(:submit_button) { { draft_button: "Save as draft" } }

          it "redirects provider to provider's applications page" do
            post_request
            expect(response).to redirect_to(submitted_providers_legal_aid_applications_path)
          end

          it "sets the application as draft" do
            expect { post_request }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
          end

          it "does not set the task to complete" do
            post_request
            expect(legal_aid_application.legal_framework_merits_task_list).to have_not_started_task(:DA001, :chances_of_success)
          end

          it "updates the model" do
            post_request
            chances_of_success.reload
            expect(chances_of_success.success_likely).to be(true)
            expect(chances_of_success.success_prospect).to eq("likely")
          end
        end

        context "when Form submitted using Continue button" do
          let(:submit_button) { { continue_button: "Continue" } }

          context "with all other tasks complete" do
            before do
              legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:DA001, :opponents_application)
            end

            it "redirects provider back to the merits task list" do
              post_request
              expect(response).to redirect_to(providers_legal_aid_application_merits_task_list_path(legal_aid_application))
            end
          end

          context "with opponents application task incomplete" do
            it "redirects provider to the opponents application task page" do
              post_request
              expect(response).to redirect_to(providers_merits_task_list_opponents_application_path(proceeding))
            end
          end

          context "with vary order issue task that is incomplete" do
            let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[da002]) }
            let(:smtl) { create(:legal_framework_merits_task_list, :da002_as_applicant, legal_aid_application:) }
            let(:proceeding) { legal_aid_application.proceedings.find_by(ccms_code: "DA002") }

            before do
              legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:DA002, :chances_of_success)
            end

            it "routes to the specific issue task" do
              post_request
              expect(response).to redirect_to(providers_merits_task_list_vary_order_path(proceeding))
            end
          end
        end
      end
    end
  end
end
