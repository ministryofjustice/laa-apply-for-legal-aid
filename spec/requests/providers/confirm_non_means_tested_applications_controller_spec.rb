require "rails_helper"

RSpec.describe Providers::ConfirmNonMeansTestedApplicationsController do
  let(:application_id) { application.id }
  let(:applicant) { build(:applicant, :under_18_for_means_test_purposes) }

  describe "GET /providers/applications/:legal_aid_application_id/confirm_non_means_tested_applications" do
    subject(:request) { get "/providers/applications/#{application_id}/confirm_non_means_tested_applications" }

    let(:application) do
      create(:legal_aid_application,
             :with_proceedings,
             :with_applicant_and_address,
             :at_checking_applicant_details,
             applicant:)
    end

    context "when the provider is not authenticated" do
      before { request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as application.provider
      end

      context "when confirm_dwp_result is not nil" do
        before do
          application.dwp_result_confirmed = true
        end

        it "resets dwp_result_confirmed to nil" do
          expect(application.reload.dwp_result_confirmed).to be_nil
        end
      end

      context "without delegated functions" do
        it "updates application state and renders template successfully with expected content", :aggregate_failures do
          expect { request }
            .to change { application.reload.state }
            .from("checking_applicant_details")
            .to("applicant_details_checked")

          expect(response).to have_http_status(:success)
          expect(response).to render_template("providers/confirm_non_means_tested_applications/show")
          expect(page).to have_content("You do not need to do a means test as your client is under 18")
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

        it "updates application state and renders template successfully with expected content", :aggregate_failures do
          expect { request }
            .to change { application.reload.state }
            .from("checking_applicant_details")
            .to("applicant_details_checked")

          expect(response).to have_http_status(:success)
          expect(response).to render_template("providers/confirm_non_means_tested_applications/show")
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

      it "has no back link" do
        expect(response.body).to have_no_link("Back")
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/confirm_non_means_tested_applications" do
    subject(:request) { patch "/providers/applications/#{application_id}/confirm_non_means_tested_applications", params: }

    let(:application) do
      create(:legal_aid_application,
             :with_proceedings,
             :with_applicant_and_address,
             :at_applicant_details_checked,
             applicant:)
    end

    context "when submitting with Continue button" do
      let(:params) do
        {
          continue_button: "Continue",
        }
      end

      before do
        login_as application.provider
      end

      it "updates dwp_result_confirmed to true" do
        expect { request }
          .to change { application.reload.dwp_result_confirmed }
          .from(nil)
          .to true
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

      it "updates application state and redirects to the next page", :aggregate_failures do
        expect { request }.to change { application.reload.state }.from("applicant_details_checked").to("provider_entering_merits")
        expect(response).to have_http_status(:redirect)
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
      end

      it "sets draft status and redirects provider to provider's applications page", :aggregate_failures do
        expect { request }.to change { application.reload.draft? }.from(false).to(true)
        expect(response).to redirect_to(in_progress_providers_legal_aid_applications_path)
      end

      it "leaves application in \"applicant_details_checked\" state" do
        expect { request }.not_to change { application.reload.state }.from("applicant_details_checked")
      end
    end
  end
end
