require "rails_helper"

RSpec.describe Providers::NoNationalInsuranceNumbersController do
  describe "GET /providers/applications/:legal_aid_application_id/no_national_insurance_number" do
    subject(:request) { get "/providers/applications/#{application.id}/no_national_insurance_number" }

    let(:application) { create(:legal_aid_application, :checking_applicant_details, applicant:) }
    let(:applicant) { create(:applicant, has_national_insurance_number:, national_insurance_number:) }

    context "when the provider is not authenticated" do
      before { request }

      let(:has_national_insurance_number) { true }
      let(:national_insurance_number) { "JA12345D" }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before { login_as application.provider }

      context "with no national insurance number" do
        let(:has_national_insurance_number) { false }
        let(:national_insurance_number) { nil }

        it "sets set state to applicant_details_checked" do
          expect { request }.to change { application.reload.state }.from("checking_applicant_details").to("applicant_details_checked")
        end

        it "sets benefit check result as skipped" do
          expect { request }.to change { application.reload.benefit_check_result&.result }.from(nil).to("skipped:no_national_insurance_number")
        end

        it "renders show" do
          request
          expect(response).to render_template("providers/no_national_insurance_numbers/show")
        end

        context "when confirm_dwp_result is not nil" do
          before do
            application.confirm_dwp_result = "dwp_correct"
          end

          it "resets confirm_dwp_result to nil" do
            expect(application.reload.confirm_dwp_result).to be_nil
          end
        end
      end

      context "with national insurance number" do
        let(:has_national_insurance_number) { true }
        let(:national_insurance_number) { "JA123456D" }

        it "redirects to check benefits" do
          request
          expect(response).to redirect_to(providers_legal_aid_application_dwp_result_path(application))
        end
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/no_national_insurance_number" do
    subject(:request) { patch("/providers/applications/#{application.id}/no_national_insurance_number", params:) }

    let(:application) { create(:legal_aid_application) }

    context "when the provider is not authenticated" do
      before { request }

      let(:params) { { continue_button: "irrelevant" } }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before { login_as application.provider }

      context "when continuing" do
        let(:params) { { continue_button: "irrelevant" } }

        it "updates confirm_dwp_result to dwp_correct" do
          request
          expect(application.reload.confirm_dwp_result).to eq "dwp_correct"
        end

        it "redirects to the next page" do
          request
          expect(response).to have_http_status(:redirect)
        end
      end

      context "when saving as draft" do
        let(:params) do
          { draft_button: "irrelevant" }
        end

        it "redirects to provider's applications page" do
          request
          expect(response).to redirect_to in_progress_providers_legal_aid_applications_path
        end
      end
    end
  end
end
