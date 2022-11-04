require "rails_helper"

RSpec.describe Providers::ProceedingMeritsTask::AttemptsToSettleController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8) }
  let(:smtl) { create(:legal_framework_merits_task_list, legal_aid_application:) }
  let(:provider) { legal_aid_application.provider }
  let(:proceeding) { legal_aid_application.proceedings.find_by(ccms_code: "SE014") }
  let(:next_page) { :merits_task_lists }

  before { allow(Flow::MeritsLoop).to receive(:forward_flow).and_return(next_page) }

  describe "GET /providers/applications/merits_task_list/:merits_task_list_id/attempts_to_settle" do
    subject { get providers_merits_task_list_attempts_to_settle_path(proceeding) }

    context "when the provider is not authenticated" do
      before { subject }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
        login_as provider
      end

      it "returns http success" do
        subject
        expect(response).to have_http_status(:ok)
      end

      it "displays the correct proceeding type as a header" do
        subject
        expect(unescaped_response_body).to include(proceeding.meaning)
      end
    end
  end

  describe "PATCH /providers/merits_task_list/:merits_task_list_id/attempts_to_settle" do
    let(:params) do
      {
        proceeding_merits_task_attempts_to_settle: {
          attempts_made: "Details of settlement attempt",
          proceeding_id: proceeding.id,
        },
      }
    end

    context "when the provider is authenticated" do
      subject do
        patch providers_merits_task_list_attempts_to_settle_path(proceeding), params: params.merge(submit_button)
      end

      before do
        allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
        login_as provider
      end

      context "when Form submitted using Continue button" do
        let(:submit_button) { { continue_button: "Continue" } }

        it "redirects provider back to the merits task list" do
          subject
          expect(response).to redirect_to(providers_legal_aid_application_merits_task_list_path(legal_aid_application))
        end

        context "when the specific issue task is incomplete" do
          let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[da001 se004]) }
          let(:smtl) { create(:legal_framework_merits_task_list, :da001_and_se004, legal_aid_application:) }
          let(:proceeding) { legal_aid_application.proceedings.find_by(ccms_code: "SE004") }

          before do
            allow(Flow::MeritsLoop).to receive(:forward_flow).and_call_original
            legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :children_application)
            legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:SE004, :chances_of_success)
            legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:SE004, :children_proceeding)
          end

          it "routes to the specific issue task" do
            subject
            expect(response).to redirect_to(providers_merits_task_list_specific_issue_path(proceeding))
          end
        end

        context "when the vary order issue task is incomplete" do
          let(:legal_aid_application) { create(:legal_aid_application, :with_proceedings, explicit_proceedings: %i[da001 se007]) }
          let(:smtl) { create(:legal_framework_merits_task_list, :da001_and_se007, legal_aid_application:) }
          let(:proceeding) { legal_aid_application.proceedings.find_by(ccms_code: "SE007") }

          before do
            allow(Flow::MeritsLoop).to receive(:forward_flow).and_call_original
            legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :children_application)
            legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:SE007, :chances_of_success)
            legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:SE007, :children_proceeding)
          end

          it "routes to the specific issue task" do
            subject
            expect(response).to redirect_to(providers_merits_task_list_vary_order_path(proceeding))
          end
        end

        context "when the application is in draft" do
          let(:legal_aid_application) do
            create(:legal_aid_application,
                   :with_multiple_proceedings_inc_section8,
                   :draft)
          end

          it "redirects provider back to the merits task list" do
            subject
            expect(response).to redirect_to(providers_legal_aid_application_merits_task_list_path(legal_aid_application))
          end

          it "sets the application as no longer draft" do
            expect { subject }.to change { legal_aid_application.reload.draft? }.from(true).to(false)
          end
        end

        it "updates the task list" do
          subject
          expect(legal_aid_application.legal_framework_merits_task_list.serialized_data).to match(/name: :attempts_to_settle\n\s+dependencies: \*\d\n\s+state: :complete/)
        end

        context "when the params are not valid" do
          let(:params) { { proceeding_merits_task_attempts_to_settle: { attempts_made: "" } } }

          it "renders the form page displaying the errors" do
            subject

            expect(unescaped_response_body).to include("There is a problem")
            expect(unescaped_response_body).to include("Enter details of any attempts to settle")
          end
        end
      end

      context "when Form submitted using Save as draft button" do
        subject do
          patch providers_merits_task_list_attempts_to_settle_path(proceeding), params: params.merge(submit_button)
        end

        let(:submit_button) { { draft_button: "Save as draft" } }

        it "redirects provider to provider's applications page" do
          subject
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end

        it "sets the application as draft" do
          expect { subject }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
        end

        it "does not set the task to complete" do
          subject
          expect(legal_aid_application.legal_framework_merits_task_list.serialized_data).not_to match(/name: :attempts_to_settle\n\s+dependencies: \*\d\n\s+state: :complete/)
        end
      end
    end
  end
end
