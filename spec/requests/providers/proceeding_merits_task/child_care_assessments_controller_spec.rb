require "rails_helper"

RSpec.describe Providers::ProceedingMeritsTask::ChildCareAssessmentsController do
  let!(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: [:pbm32]) }
  let(:smtl) { create(:legal_framework_merits_task_list, :pbm32_as_applicant, legal_aid_application:) }
  let(:proceeding) { legal_aid_application.proceedings.find_by(ccms_code: "PBM32") }
  let(:provider) { legal_aid_application.provider }

  before { allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl) }

  describe "GET /providers/merits_task_list/:id/child_care_assessments" do
    subject(:get_request) { get providers_merits_task_list_child_care_assessment_path(proceeding) }

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
        expect(response).to render_template("providers/proceeding_merits_task/child_care_assessments/show")
      end
    end
  end

  describe "PATCH providers/merits_task_list/:id/child_care_assessments" do
    subject(:patch_request) { patch providers_merits_task_list_child_care_assessment_path(proceeding), params: params.merge(submit_button) }

    let(:params) do
      {
        proceeding_merits_task_child_care_assessment: {
          assessed:,
        },
      }
    end

    context "when the provider is not authenticated" do
      before { patch_request }

      let(:assessed) { "true" }
      let(:submit_button) { { continue_button: "Continue" } }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before { login_as provider }

      context "with Continue button pressed" do
        let(:assessed) { "true" }
        let(:submit_button) { { continue_button: "Continue" } }

        it "creates the child_care_assessment record" do
          expect { patch_request }.to change { proceeding.reload.child_care_assessment }
            .from(nil)
            .to(instance_of(ProceedingMeritsTask::ChildCareAssessment))
        end

        it "updates the child_care_assessment assessed" do
          expect { patch_request }.to change { proceeding.reload.child_care_assessment&.reload&.assessed }
            .from(nil)
            .to(true)
        end

        it "redirects to the next page" do
          patch_request
          expect(response).to have_http_status(:redirect)
        end

        context "when yes selected" do
          let(:assessed) { "true" }

          it "leaves the task as not_started" do
            patch_request
            expect(legal_aid_application.legal_framework_merits_task_list)
              .to have_task_in_state(:PBM32, :client_child_care_assessment, :not_started)
          end

          it "redirects to the assessment result page" do
            patch_request
            expect(response).to redirect_to(providers_merits_task_list_child_care_assessment_result_path)
          end
        end

        context "when no selected" do
          let(:assessed) { "false" }

          it "updates the task to be completed" do
            patch_request
            expect(legal_aid_application.legal_framework_merits_task_list)
              .to have_task_in_state(:PBM32, :client_child_care_assessment, :complete)
          end

          it "redirects to the next page in flow" do
            allow(Flow::MeritsLoop).to receive(:forward_flow).and_return(:check_merits_answers)

            patch_request
            expect(response).to redirect_to(providers_legal_aid_application_check_merits_answers_path(legal_aid_application))
          end
        end

        context "when nothing selected" do
          let(:assessed) { nil }

          it "renders show" do
            patch_request
            expect(response)
              .to have_http_status(:ok)
              .and render_template("providers/proceeding_merits_task/child_care_assessments/show")
          end

          it "displays expected error" do
            patch_request
            expect(page)
              .to have_content("Select yes if the local authority has assessed your client's ability to care for the children involved")
          end
        end

        context "when assessed changed from yes to no" do
          before do
            create(:child_care_assessment, :negative_assessment, assessed: true, proceeding:)
          end

          let(:assessed) { "false" }

          it "clears the assessment result and details" do
            expect { patch_request }
              .to change { proceeding.child_care_assessment.reload.attributes.symbolize_keys }
                .from(hash_including(result: false, details: instance_of(String)))
                .to(hash_including(result: nil, details: nil))
          end
        end

        context "when assessed changed from no to yes" do
          before do
            create(:child_care_assessment, :positive_assessment, assessed: false, proceeding:)
          end

          let(:assessed) { "true" }

          it "clears the assessment result (and details)" do
            expect { patch_request }
              .to change { proceeding.child_care_assessment.reload.attributes.symbolize_keys }
                .from(hash_including(result: true, details: nil))
                .to(hash_including(result: nil, details: nil))
          end
        end
      end

      context "with Save as draft button pressed" do
        let(:assessed) { "true" }
        let(:submit_button) { { draft_button: "Save as draft" } }

        it "creates the child_care_assessment record" do
          expect { patch_request }.to change { proceeding.reload.child_care_assessment }
            .from(nil)
            .to(instance_of(ProceedingMeritsTask::ChildCareAssessment))
        end

        it "updates the child_care_assessment assessed" do
          expect { patch_request }.to change { proceeding.reload.child_care_assessment&.reload&.assessed }
            .from(nil)
            .to(true)
        end

        it "redirects to provider applications home page" do
          patch_request
          expect(response).to redirect_to submitted_providers_legal_aid_applications_path
        end

        context "when yes selected" do
          let(:assessed) { "true" }

          it "leaves the task as not_started" do
            patch_request
            expect(legal_aid_application.legal_framework_merits_task_list)
              .to have_task_in_state(:PBM32, :client_child_care_assessment, :not_started)
          end

          it "redirects to provider applications home page" do
            patch_request
            expect(response).to redirect_to submitted_providers_legal_aid_applications_path
          end
        end

        context "when no selected" do
          let(:assessed) { "false" }

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
          let(:assessed) { nil }

          it "redirects to provider applications home page" do
            patch_request
            expect(response).to redirect_to submitted_providers_legal_aid_applications_path
          end

          it "leaves the task as not_started" do
            patch_request
            expect(legal_aid_application.legal_framework_merits_task_list)
              .to have_task_in_state(:PBM32, :client_child_care_assessment, :not_started)
          end
        end

        context "when assessed changed from yes to no" do
          before do
            create(:child_care_assessment, :negative_assessment, assessed: true, proceeding:)
          end

          let(:assessed) { "false" }

          it "clears the assessment result and details" do
            expect { patch_request }
              .to change { proceeding.child_care_assessment.reload.attributes.symbolize_keys }
                .from(hash_including(result: false, details: instance_of(String)))
                .to(hash_including(result: nil, details: nil))
          end
        end

        context "when assessed changed from no to yes" do
          before do
            create(:child_care_assessment, :positive_assessment, assessed: false, proceeding:)
          end

          let(:assessed) { "true" }

          it "clears the assessment result (and details)" do
            expect { patch_request }
              .to change { proceeding.child_care_assessment.reload.attributes.symbolize_keys }
                .from(hash_including(result: true, details: nil))
                .to(hash_including(result: nil, details: nil))
          end
        end
      end
    end
  end
end
