require "rails_helper"

RSpec.describe Providers::ConfirmNonMeansTestedApplicationsController do
  let(:application) do
    create(:legal_aid_application,
           :with_proceedings,
           :with_applicant_and_address,
           :with_non_means_tested_state_machine,
           :at_checking_applicant_details)
  end

  let(:application_id) { application.id }

  describe "GET /providers/applications/:legal_aid_application_id/confirm_non_means_tested_applications" do
    subject(:request) { get "/providers/applications/#{application_id}/confirm_non_means_tested_applications" }

    context "when the provider is not authenticated" do
      before { request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as application.provider
      end

      it "is successful" do
        request
        expect(response).to be_successful
      end

      it { expect(request).to render_template("providers/confirm_non_means_tested_applications/show") }

      it "transitions the application state to applicant details check" do
        expect { request }
          .to change { application.reload.state }
          .from("checking_applicant_details")
          .to("applicant_details_checked")
      end

      context "without delegated functions" do
        it "displays expected content" do
          request
          expect(page).to have_content("No means test required as client is under 18")
        end
      end

      context "with delegated functions" do
        before do
          application.proceedings
            .first
            .update!(used_delegated_functions: true,
                     used_delegated_functions_on: Date.current,
                     used_delegated_functions_reported_on: Date.current)
        end

        it "displays expected content" do
          request
          expect(page).to have_content("You do not need to do a means test as your client was under 18 when you first used delegated functions on this case")
        end
      end
    end

    describe "back link" do
      let(:page) { providers_legal_aid_application_check_provider_answers_path(application) }

      before do
        login_as application.provider
        get page
        request
      end

      it "takes you back to check your answers page" do
        expect(response.body).to have_back_link("#{page}&back=true")
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/confirm_non_means_tested_applications" do
    subject(:request) { patch "/providers/applications/#{application_id}/confirm_non_means_tested_applications", params: }

    context "when submitting with Continue button" do
      let(:params) do
        {
          continue_button: "Continue",
        }
      end

      before do
        login_as application.provider
        allow(Setting).to receive(:means_test_review_phase_one?).and_return(true)
      end

      it "creates a skipped benefit check result" do
        expect { request }
          .to change { application.reload.benefit_check_result&.result }
          .from(nil)
          .to("skipped:no_means_test_required")
      end

      it "creates a no assessment cfe result" do
        expect { request }
          .to change { application.reload.cfe_result&.income_assessment_result }
          .from(nil)
          .to("no_assessment")
      end

      it "redirects to the merits task list page" do
        request
        expect(response).to redirect_to(providers_legal_aid_application_merits_task_list_path(application))
      end
    end

    context "when submitting with Save As Draft button" do
      let(:params) do
        {
          draft_button: "Save as draft",
        }
      end

      before do
        login_as application.provider
        request
      end

      it "redirects provider to provider's applications page" do
        expect(response).to redirect_to(providers_legal_aid_applications_path)
      end

      it "sets the application as draft" do
        expect(application.reload).to be_draft
      end
    end
  end
end
