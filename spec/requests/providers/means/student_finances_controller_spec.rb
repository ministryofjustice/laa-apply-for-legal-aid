require "rails_helper"

RSpec.describe Providers::Means::StudentFinancesController do
  let(:legal_aid_application) { create(:legal_aid_application, applicant:) }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:legal_aid_application_id/means/student_finance" do
    subject(:request) do
      get providers_legal_aid_application_means_student_finance_path(legal_aid_application)
    end

    let(:applicant) { create(:applicant, student_finance:, student_finance_amount: 1234.56) }
    let(:student_finance) { true }

    it "returns ok" do
      login_as provider
      request

      expect(response).to have_http_status(:ok)
    end

    context "when the application has student finance" do
      it "checks the 'Yes' radio button and displays the amount" do
        login_as provider
        request

        expect(page).to have_checked_field("Yes")
        expect(page).to have_field("applicant[student_finance_amount]", with: "1234.56")
      end
    end

    context "when the application does not have student finance" do
      let(:student_finance) { false }

      it "checks the 'No' radio button" do
        login_as provider
        request

        expect(page).to have_checked_field("No")
      end
    end

    context "when the provider is not authenticated" do
      before { request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is not authorised" do
      before do
        login_as create(:provider)
        request
      end

      it_behaves_like "an authenticated provider from a different firm"
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/means/student_finance" do
    subject(:request) do
      patch providers_legal_aid_application_means_student_finance_path(legal_aid_application),
            params: params.merge(button_clicked)
    end

    let(:applicant) { create(:applicant, student_finance:, student_finance_amount:) }
    let(:params) { { applicant: { student_finance:, student_finance_amount: } } }
    let(:student_finance) { "false" }
    let(:student_finance_amount) { nil }
    let(:button_clicked) { {} }
    let(:continue_button) { { continue_button: "Save and continue" } }

    context "when the provider continues" do
      let(:button_clicked) { continue_button }

      context "when the provider selects `Yes`" do
        let(:student_finance) { "true" }
        let(:student_finance_amount) { "5000" }

        it "updates the applicant" do
          login_as provider
          request

          expect(applicant.reload.student_finance).to be true
          expect(applicant.reload.student_finance_amount).to eq 5000
        end
      end

      context "when the provider selects `No`" do
        it "updates the applicant" do
          login_as provider
          request

          expect(applicant.reload.student_finance).to be false
          expect(applicant.reload.student_finance_amount).to be_nil
        end
      end

      context "when the application is using the bank upload journey" do
        let(:legal_aid_application) { create(:legal_aid_application, :without_open_banking_consent, :with_applicant) }

        it "redirects to the next page" do
          login_as provider
          request

          expect(response).to have_http_status(:redirect)
        end
      end

      context "when the application is not using the bank upload journey" do
        it "redirects to the next page" do
          login_as provider

          request

          expect(response).to have_http_status(:redirect)
        end
      end
    end

    context "when the application has student finance" do
      let(:student_finance) { "true" }
      let(:student_finance_amount) { "1234.56" }

      it "updates the student finance amount" do
        applicant
        login_as provider
        request

        expect(applicant.reload.student_finance_amount).to eq(1234.56)
      end
    end

    context "when the form is invalid" do
      let(:student_finance) { "" }

      it "displays an error message" do
        login_as provider

        request

        expect(page).to have_error_message(
          "Select yes if your client receives student finance",
        )
      end
    end

    context "when the provider is not authenticated" do
      before { request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is not authorised" do
      before do
        login_as create(:provider)
        request
      end

      it_behaves_like "an authenticated provider from a different firm"
    end

    context "when form submitted with Save as draft button" do
      let(:params) do
        {
          applicant: { student_finance:, student_finance_amount: },
          draft_button: "Save and come back later",
        }
      end

      it "redirects to the list of applications" do
        login_as provider
        request
        expect(response).to redirect_to submitted_providers_legal_aid_applications_path
      end
    end
  end
end
