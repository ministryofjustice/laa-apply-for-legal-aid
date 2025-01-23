require "rails_helper"

RSpec.describe Providers::ProceedingMeritsTask::ChildCareAssessmentResultsController do
  let!(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: [:pbm32]) }
  let(:smtl) { create(:legal_framework_merits_task_list, :pbm32_as_applicant, legal_aid_application:) }
  let(:proceeding) { legal_aid_application.proceedings.find_by(ccms_code: "PBM32") }
  let(:provider) { legal_aid_application.provider }

  before do
    create(:child_care_assessment, assessed: true, proceeding:)
    allow(Flow::MeritsLoop).to receive(:forward_flow).and_return(:check_merits_answers)
    allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
  end

  describe "GET /providers/merits_task_list/:id/child_care_assessment_results" do
    subject(:get_request) { get providers_merits_task_list_child_care_assessment_result_path(proceeding) }

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
        expect(response).to render_template("providers/proceeding_merits_task/child_care_assessment_results/show")
      end
    end
  end

  describe "PATCH providers/merits_task_list/:id/child_care_assessment_results" do
    subject(:patch_request) { patch providers_merits_task_list_child_care_assessment_result_path(proceeding), params: params.merge(submit_button) }

    let(:params) do
      {
        proceeding_merits_task_child_care_assessment: {
          result:,
          details:,
        },
      }
    end

    context "when the provider is not authenticated" do
      before { patch_request }

      let(:result) { "true" }
      let(:details) { nil }
      let(:submit_button) { { continue_button: "Continue" } }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before { login_as provider }

      context "with Continue button pressed" do
        let(:result) { "true" }
        let(:details) { nil }
        let(:submit_button) { { continue_button: "Continue" } }

        it "updates the child_care_assessment result" do
          expect { patch_request }.to change { proceeding.reload.child_care_assessment&.reload&.result }
            .from(nil)
            .to(true)
        end

        it "redirects to the next page" do
          patch_request
          expect(response).to have_http_status(:redirect)
        end

        context "when positive selected" do
          let(:result) { "true" }

          it "updates the task to be completed" do
            patch_request
            expect(legal_aid_application.legal_framework_merits_task_list)
              .to have_task_in_state(:PBM32, :client_child_care_assessment, :complete)
          end

          it "redirects to the next page in flow" do
            allow(Flow::MeritsLoop).to receive(:forward_flow).and_return(:check_merits_answers)

            patch_request
            expect(response)
              .to redirect_to(providers_legal_aid_application_check_merits_answers_path(legal_aid_application))
          end
        end

        context "when negative selected with details" do
          let(:result) { "false" }
          let(:details) { "challenge reason" }

          it "updates the task to be completed" do
            patch_request
            expect(legal_aid_application.legal_framework_merits_task_list)
              .to have_task_in_state(:PBM32, :client_child_care_assessment, :complete)
          end

          it "redirects to the next page in flow" do
            allow(Flow::MeritsLoop).to receive(:forward_flow).and_return(:check_merits_answers)

            patch_request
            expect(response)
              .to redirect_to(providers_legal_aid_application_check_merits_answers_path(legal_aid_application))
          end
        end

        context "when negative selected without details" do
          let(:result) { "false" }
          let(:details) { nil }

          it "does NOT update the task to be completed" do
            patch_request
            expect(legal_aid_application.legal_framework_merits_task_list)
              .to have_task_in_state(:PBM32, :client_child_care_assessment, :not_started)
          end

          it "renders show" do
            patch_request
            expect(response)
              .to have_http_status(:ok)
              .and render_template("providers/proceeding_merits_task/child_care_assessment_results/show")
          end

          it "displays expected error" do
            patch_request
            expect(page)
              .to have_content("Enter how the negative assessment will be challenged")
          end
        end

        context "when nothing selected" do
          let(:result) { nil }

          it "renders show" do
            patch_request
            expect(response)
              .to have_http_status(:ok)
              .and render_template("providers/proceeding_merits_task/child_care_assessment_results/show")
          end

          it "displays expected error" do
            patch_request
            expect(page)
              .to have_content("Select if the assessment was positive or negative")
          end
        end

        context "when result changed from negative to positive" do
          before do
            proceeding.child_care_assessment.update!(result: false, details: "we will challenge the negative decision...")
          end

          let(:params) do
            {
              proceeding_merits_task_child_care_assessment: {
                result: "true",
              },
            }
          end

          it "clears the assessment negative result details" do
            expect { patch_request }
              .to change { proceeding.child_care_assessment.reload.attributes.symbolize_keys }
                .from(hash_including(result: false, details: instance_of(String)))
                .to(hash_including(result: true, details: nil))
          end
        end
      end

      context "with Save as draft button pressed" do
        let(:result) { "true" }
        let(:details) { nil }
        let(:submit_button) { { draft_button: "Save as draft" } }

        it "updates the child_care_assessment result" do
          expect { patch_request }.to change { proceeding.reload.child_care_assessment&.reload&.result }
            .from(nil)
            .to(true)
        end

        it "redirects to provider applications home page" do
          patch_request
          expect(response).to redirect_to submitted_providers_legal_aid_applications_path
        end

        context "when positive selected" do
          let(:result) { "true" }

          it "does NOT update the task to be completed" do
            patch_request
            expect(legal_aid_application.legal_framework_merits_task_list)
              .to have_task_in_state(:PBM32, :client_child_care_assessment, :not_started)
          end

          it "redirects to provider applications home page" do
            patch_request
            expect(response).to redirect_to submitted_providers_legal_aid_applications_path
          end
        end

        context "when negative selected with details" do
          let(:result) { "false" }
          let(:details) { "challenge reason" }

          it "does NOT update the task to be completed" do
            patch_request
            expect(legal_aid_application.legal_framework_merits_task_list)
              .to have_task_in_state(:PBM32, :client_child_care_assessment, :not_started)
          end

          it "redirects to provider applications home page" do
            patch_request
            expect(response).to redirect_to submitted_providers_legal_aid_applications_path
          end
        end

        context "when negative selected without details" do
          let(:result) { "false" }
          let(:details) { nil }

          it "does NOT update the task to be completed" do
            patch_request
            expect(legal_aid_application.legal_framework_merits_task_list)
              .to have_task_in_state(:PBM32, :client_child_care_assessment, :not_started)
          end

          it "redirects to provider applications home page" do
            patch_request
            expect(response).to redirect_to submitted_providers_legal_aid_applications_path
          end
        end

        context "when nothing selected" do
          let(:result) { nil }

          it "does NOT update the task to be completed" do
            patch_request
            expect(legal_aid_application.legal_framework_merits_task_list)
              .to have_task_in_state(:PBM32, :client_child_care_assessment, :not_started)
          end

          it "redirects to provider applications home page" do
            patch_request
            expect(response).to redirect_to submitted_providers_legal_aid_applications_path
          end
        end

        context "when result changed from negative to positive" do
          before do
            proceeding.child_care_assessment.update!(result: false, details: "we will challenge the negative decision...")
          end

          let(:params) do
            {
              proceeding_merits_task_child_care_assessment: {
                result: "true",

              },
            }
          end

          it "clears the assessment negative result details" do
            expect { patch_request }
              .to change { proceeding.child_care_assessment.reload.attributes.symbolize_keys }
                .from(hash_including(result: false, details: instance_of(String)))
                .to(hash_including(result: true, details: nil))
          end

          it "redirects to provider applications home page" do
            patch_request
            expect(response).to redirect_to submitted_providers_legal_aid_applications_path
          end
        end
      end
    end
  end
end
