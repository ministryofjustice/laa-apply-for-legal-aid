require "rails_helper"

RSpec.describe Providers::ConfirmNonMeansTestedApplicationsController do
  let(:application) { create(:legal_aid_application, :with_proceedings, :at_checking_applicant_details, :with_applicant_and_address) }
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
        request
      end

      it "returns success" do
        expect(response).to be_successful
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
    context "when submitting with Continue button" do
      subject(:request) { patch "/providers/applications/#{application_id}/confirm_non_means_tested_applications", params: }

      let(:params) do
        {
          continue_button: "Continue",
        }
      end

      before do
        login_as application.provider
        Setting.setting.update!(means_test_review_phase_one: true)
        request
      end

      it "creates a skipped benefit check result" do
        expect(application.benefit_check_result.result).to eq "skipped:no_means_test_required"
      end

      it "creates a no assessment cfe result" do
        expect(application.cfe_result.income_assessment_result).to eq "no_assessment"
      end

      it "transitions the application state to applicant details check" do
        expect(application.reload.state).to be "applicant_details_checked"
      end

      it "redirects to the merits task list page" do
        expect(response).to redirect_to(providers_legal_aid_application_merits_task_list_path(application))
      end

      it "uses the non means tested state machine" do
        expect(application.reload.state_machine_proxy.type).to eq "NonMeansTestedStateMachine"
      end
    end

    context "when submitting with Save As Draft button" do
      subject(:request) { patch "/providers/applications/#{application_id}/confirm_non_means_tested_applications", params: }

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
