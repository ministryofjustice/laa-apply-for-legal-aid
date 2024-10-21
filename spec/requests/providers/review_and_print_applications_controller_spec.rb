require "rails_helper"

RSpec.describe Providers::ReviewAndPrintApplicationsController do
  let(:application) do
    create(:legal_aid_application,
           :with_everything,
           :with_proceedings,
           :with_chances_of_success,
           :with_attempts_to_settle,
           :with_involved_children,
           :with_cfe_v5_result,
           :provider_entering_merits,
           proceeding_count: 3)
  end
  let(:provider) { application.provider }
  let(:smtl) { create(:legal_framework_merits_task_list, :da001_da004_se014, legal_aid_application: application) }

  before { allow(LegalFramework::MeritsTasksService).to receive(:call).with(application).and_return(smtl) }

  describe "GET /providers/applications/:id/review_and_print_application" do
    subject(:request) { get providers_legal_aid_application_review_and_print_application_path(application) }

    context "when the provider is not authenticated" do
      before { request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        request
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the confirm client declaration page" do
        expect(response).to render_template("providers/review_and_print_applications/show")
        expect(response.body).to include("Review and print your application")
      end
    end
  end

  describe "PATCH /providers/applications/:id/review_and_print_application/continue" do
    subject(:request) { patch "/providers/applications/#{application.id}/review_and_print_application/continue", params: }

    let(:application) do
      create(:legal_aid_application,
             :with_everything,
             :with_proceedings,
             :checking_merits_answers,
             proceeding_count: 3)
    end
    let(:allow_ccms_submission) { true }
    let(:params) { {} }

    before { allow(EnableCCMSSubmission).to receive(:call).and_return(allow_ccms_submission) }

    context "when logged in as an authenticated provider" do
      before do
        login_as application.provider
      end

      context "when continue button pressed" do
        let(:submit_button) { { continue_button: "Continue" } }

        it "updates the record" do
          expect { request }.to change { application.reload.merits_submitted_at }.from(nil)
          expect(application.reload).to be_generating_reports
        end

        it "redirects to next page" do
          request
          expect(response).to have_http_status(:redirect)
        end

        it "creates pdf reports" do
          ReportsCreatorWorker.clear
          expect(Reports::ReportsCreator).to receive(:call).with(application)
          request
          ReportsCreatorWorker.drain
        end

        it "sets the merits assessment to submitted" do
          request
          expect(application.reload.summary_state).to eq :submitted
        end

        context "when the Setting.enable_ccms_submission?is turned on" do
          it "transitions to generating_reports state" do
            request
            expect(application.reload).to be_generating_reports
          end
        end

        context "when the Setting.enable_ccms_submission? is turned off" do
          let(:allow_ccms_submission) { false }

          it "transitions to submission_paused state" do
            request
            expect(application.reload.state).to eq "submission_paused"
          end
        end
      end

      context "when form submitted using Save as draft button" do
        let(:params) { { draft_button: "Save as draft" } }

        it "redirect provider to provider's applications page" do
          request
          expect(response).to redirect_to(submitted_providers_legal_aid_applications_path)
        end

        it "sets the application as draft" do
          request
          expect(application.reload).to be_draft
        end
      end
    end

    context "when unauthenticated" do
      before { request }

      it_behaves_like "a provider not authenticated"
    end
  end
end
