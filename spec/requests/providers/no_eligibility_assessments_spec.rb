require "rails_helper"

RSpec.describe "Providers::NoEligibilityAssessmentsController" do
  let(:login_provider) { login_as legal_aid_application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/no_eligibility_assessments" do
    subject(:request) { get providers_legal_aid_application_no_eligibility_assessment_path(legal_aid_application) }

    let(:legal_aid_application) { create(:legal_aid_application, :with_attached_bank_statement, :with_transaction_period, :checking_non_passported_means, :with_proceedings, :with_employed_applicant) }

    before do
      login_provider
    end

    it "returns http success" do
      request
      expect(response).to have_http_status(:ok)
    end

    it "displays the correct panel" do
      request
      expect(unescaped_response_body).to include(I18n.t(".providers.no_eligibility_assessments.show.cannot_calculate"))
      expect(unescaped_response_body).to include(I18n.t(".providers.no_eligibility_assessments.show.caseworker_check"))
      expect(unescaped_response_body).to include(I18n.t(".providers.no_eligibility_assessments.show.continue"))
    end

    it "writes an empty cfe_result if there is no HMRC data" do
      request
      expect(legal_aid_application.cfe_result.assessment_result).to eq "no_assessment"
    end

    context "when there is a hmrc response" do
      before do
        allow(legal_aid_application).to receive(:calculation_date).and_return(Time.zone.today)
        allow(CFE::SubmissionManager).to receive(:call)
        create(:hmrc_response, :use_case_one, legal_aid_application_id: legal_aid_application.id)
      end

      it "calls cfe when hmrc data exists" do
        request
        expect(CFE::SubmissionManager).to have_received(:call)
      end
    end
  end

  describe "PATCH /providers/applications/:id/capital_income_assessment_result" do
    subject(:request) { patch providers_legal_aid_application_no_eligibility_assessment_path(legal_aid_application), params: params.merge(submit_button) }

    let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
    let(:params) { {} }

    context "when the provider is authenticated" do
      before do
        login_provider
      end

      context "when the continue button is pressed" do
        let(:submit_button) { { continue_button: "Save and continue" } }

        it "redirects to the merits task list" do
          request
          expect(request).to redirect_to(providers_legal_aid_application_merits_task_list_path)
        end
      end

      context "when the save as draft button is pressed" do
        let(:submit_button) { { draft_button: "Save and come back later" } }

        it "redirects provider to provider's applications page" do
          request
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end

        it "sets the application as draft" do
          request
          expect(legal_aid_application.reload).to be_draft
        end
      end
    end
  end
end
