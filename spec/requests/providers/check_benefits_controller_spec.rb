require "rails_helper"

RSpec.describe Providers::CheckBenefitsController do
  let(:last_name) { "WALKER" }
  let(:date_of_birth) { "1980/01/10".to_date }
  let(:has_national_insurance_number) { true }
  let(:national_insurance_number) { "JA293483A" }
  let(:applicant) { create(:applicant, last_name:, date_of_birth:, national_insurance_number:, has_national_insurance_number:) }
  let(:application) { create(:application, :checking_applicant_details, applicant:) }
  let(:login) { login_as application.provider }
  let(:provider) { create(:provider) }

  describe "GET /providers/applications/:application_id/check_benefit", :vcr do
    subject(:get_request) { get "/providers/applications/#{application.id}/check_benefit" }

    before { login }

    it "returns http success" do
      get_request
      expect(response).to have_http_status(:ok)
    end

    it "generates a new check_benefit_result" do
      expect { get_request }.to change(BenefitCheckResult, :count).by(1)
    end

    it "has not transitioned the state" do
      get_request
      expect(application.reload.state).to eq "checking_applicant_details"
    end

    context "when state is provider_entering_means" do
      let(:application) { create(:application, :provider_entering_means, applicant:) }

      it "transitions from provider_entering_means" do
        get_request
        expect(application.reload.state).to eq "provider_entering_means"
      end
    end

    context "when the check_benefit_result already exists" do
      it "does not generate a new one" do
        create(:benefit_check_result, legal_aid_application: application)
        expect(BenefitCheckService).not_to receive(:call)
        expect { get_request }.not_to change(BenefitCheckResult, :count)
      end

      context "and the applicant has since been modified" do
        it "updates check_benefit_result" do
          applicant.update!(first_name: Faker::Name.first_name)
          travel(-10.minutes) { create(:benefit_check_result, legal_aid_application: application) }
          expect(BenefitCheckService).to receive(:call).and_call_original
          get_request
        end
      end
    end

    context "with known issue" do
      let(:last_name) { "O" }

      it "skips benefit check marking it as a known issue" do
        get_request
        expect(application.reload.benefit_check_result&.result).to eq("skipped:known_issue")
      end

      it "redirects to next step" do
        get_request
        expect(response).to redirect_to(flow_forward_path)
      end
    end

    context "when the benefit check service is down" do
      before { allow(BenefitCheckService).to receive(:call).and_return(false) }

      it "redirects to the Problem page" do
        get_request
        expect(response).to redirect_to(problem_index_path)
      end
    end

    context "when the provider is not authenticated" do
      let(:login) { nil }

      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the check benefit result is positive" do
      let(:application) { create(:legal_aid_application, :with_applicant, :with_proceedings, :with_positive_benefit_check_result, :at_checking_applicant_details) }

      it "displays the passported result page" do
        get_request
        expect(response.body).to include "DWP records show that your client receives a passporting benefit"
      end
    end

    context "when the check benefit result is negative" do
      let(:application) { create(:legal_aid_application, :with_applicant, :with_proceedings, :with_negative_benefit_check_result, :at_checking_applicant_details) }

      it "displays the confirm dwp non passported_applications page" do
        get_request
        expect(response).to redirect_to providers_legal_aid_application_confirm_dwp_non_passported_applications_path(application)
      end
    end
  end

  describe "PATCH /providers/applications/:application_id/check_benefit" do
    subject(:patch_request) { patch providers_legal_aid_application_check_benefit_path(application.id), params: }

    before do
      login
      application.reload
      application.proceedings.map(&:reload)
      patch_request
    end

    context "with form submitted with Continue button" do
      let(:params) do
        {
          continue_button: "Continue",
        }
      end

      context "when the check_benefit_results is positive" do
        let(:application) { create(:legal_aid_application, :with_positive_benefit_check_result) }

        it "displays the capital introduction page" do
          expect(response).to redirect_to providers_legal_aid_application_capital_introduction_path(application)
        end
      end

      context "when the check benefit result is negative" do
        let(:application) { create(:legal_aid_application, :with_negative_benefit_check_result) }

        it "displays the applicant employed page" do
          expect(response).to redirect_to providers_legal_aid_application_applicant_employed_index_path(application)
        end
      end

      context "when the check benefit result is undetermined" do
        let(:application) { create(:legal_aid_application, :with_undetermined_benefit_check_result) }

        it "displays the applicant employed page" do
          expect(response).to redirect_to providers_legal_aid_application_applicant_employed_index_path(application)
        end
      end

      context "when delegated functions used" do
        let!(:application) do
          create(:legal_aid_application,
                 :with_positive_benefit_check_result,
                 :with_proceedings,
                 :with_delegated_functions_on_proceedings,
                 explicit_proceedings: [:da004],
                 df_options: { DA004: [Time.zone.today, Time.zone.today] })
        end

        it "displays the substantive application page" do
          expect(response).to redirect_to providers_legal_aid_application_substantive_application_path(application)
        end
      end
    end

    context "with form submitted with Save as draft button" do
      let(:params) do
        {
          draft_button: "Save as draft",
        }
      end

      context "when the check_benefit_results is positive" do
        let(:application) { create(:legal_aid_application, :with_positive_benefit_check_result) }

        it "displays the providers applications page" do
          expect(response).to redirect_to submitted_providers_legal_aid_applications_path
        end

        it "sets the application as draft" do
          expect(application.reload).to be_draft
        end
      end

      context "when the check benefit result is negative" do
        let(:application) { create(:legal_aid_application, :with_negative_benefit_check_result) }

        it "displays providers applications page" do
          expect(response).to redirect_to submitted_providers_legal_aid_applications_path
        end
      end

      context "when the check benefit result is undetermined" do
        let(:application) { create(:legal_aid_application, :with_undetermined_benefit_check_result) }

        it "displays providers applications page" do
          expect(response).to redirect_to submitted_providers_legal_aid_applications_path
        end
      end
    end
  end

  describe "allowed to continue or use ccms?" do
    before { login_as provider }

    context "with application passported" do
      let(:application) { create(:legal_aid_application, :with_positive_benefit_check_result, :checking_applicant_details, applicant:, provider:) }

      it "displays positive DWP result content" do
        get "/providers/applications/#{application.id}/check_benefit"
        expect(response.body).to include("DWP records show that your client receives a passporting benefit")
      end
    end
  end
end
