require "rails_helper"

RSpec.describe Providers::ClientCompletedMeansController do
  let(:legal_aid_application) { create(:legal_aid_application, applicant:, partner:) }
  let(:applicant) { create(:applicant, :employed, has_partner:) }
  let(:has_partner) { false }
  let(:partner) { nil }
  let(:provider) { legal_aid_application.provider }
  let(:enable_partner_means) { false }

  before { allow(Setting).to receive(:partner_means_assessment?).and_return(enable_partner_means) }

  describe "GET /providers/applications/:id/client_completed_means" do
    subject { get providers_legal_aid_application_client_completed_means_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { subject }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        subject
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Your client has shared their financial information")
      end

      context "when the applicant has no partner" do
        context "and the applicant is not employed" do
          let(:applicant) { create(:applicant, :not_employed) }

          it "does not include reviewing employment details in action list" do
            expect(response.body).to include("1. Tell us about their income and outgoings")
            expect(response.body).to include("2. Sort their bank transactions into categories")
            expect(response.body).to include("3. Tell us about their dependants")
            expect(response.body).to include("4. Tell us about their capital")
            expect(response.body).not_to include("Review their employment income")
          end

          it "includes income and outgoings as first point" do
            expect(response.body).to include("1. Tell us about their income and outgoings")
          end
        end

        context "and the applicant is employed" do
          it "includes reviewing employment details in action list" do
            expect(response.body).to include("1. Review their employment income")
            expect(response.body).to include("2. Tell us about their income and outgoings")
            expect(response.body).to include("3. Sort their bank transactions into categories")
            expect(response.body).to include("4. Tell us about their dependants")
            expect(response.body).to include("5. Tell us about their capital")
          end
        end
      end

      context "when the applicant has a partner" do
        let(:has_partner) { true }
        let(:partner) { create(:partner) }

        context "and the applicant is not employed" do
          let(:applicant) { create(:applicant, :not_employed, has_partner:) }

          it "the steps list only includes one option" do
            expect(response.body).to include("1. Tell us about their income and outgoings")
            expect(response.body).not_to include("Sort their bank transactions into categories")
            expect(response.body).not_to include("Tell us about their dependants")
            expect(response.body).not_to include("Tell us about their capital")
          end
        end

        context "when the applicant is employed" do
          it "the steps list only includes two options" do
            expect(response.body).to include("1. Review their employment income")
            expect(response.body).to include("2. Tell us about their income and outgoings")
            expect(response.body).not_to include("Sort their bank transactions into categories")
            expect(response.body).not_to include("Tell us about their dependants")
            expect(response.body).not_to include("Tell us about their capital")
          end
        end
      end
    end
  end

  describe "PATCH /providers/applications/:id/client_completed_means" do
    subject { patch providers_legal_aid_application_client_completed_means_path(legal_aid_application), params: params.merge(submit_button) }

    let(:params) { {} }

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      context "Continue button pressed" do
        let(:submit_button) { { continue_button: "Continue" } }

        context "employment income data was received from HMRC" do
          before do
            allow_any_instance_of(Applicant).to receive(:hmrc_employment_income?).and_return(true)
            allow_any_instance_of(Applicant).to receive(:has_multiple_employments?).and_return(false)
          end

          it "redirects to the employment income page" do
            subject
            expect(response).to redirect_to(providers_legal_aid_application_means_employment_income_path(legal_aid_application))
          end
        end

        context "unknown result obtained from HMRC::StatusAnalyzer" do
          before do
            allow(HMRC::StatusAnalyzer).to receive(:call).with(legal_aid_application).and_return(:xxx)
          end

          it "raises an error" do
            expect { subject }.to raise_error RuntimeError, "Unexpected hmrc status :xxx"
          end
        end

        context "no employment income data was received from HMRC" do
          before { allow_any_instance_of(LegalAidApplication).to receive(:hmrc_employment_income?).and_return(false) }

          it "redirects to the no employed income page" do
            subject
            expect(response).to redirect_to(providers_legal_aid_application_means_full_employment_details_path(legal_aid_application))
          end
        end

        context "employment income data for multiple jobs was received from HMRC" do
          before do
            allow_any_instance_of(LegalAidApplication).to receive(:hmrc_employment_income?).and_return(true)
            allow_any_instance_of(LegalAidApplication).to receive(:has_multiple_employments?).and_return(true)
          end

          it "redirects to the no employed income page" do
            subject
            expect(response).to redirect_to(providers_legal_aid_application_means_full_employment_details_path(legal_aid_application))
          end
        end

        context "transactions exist, and applicant is not employed" do
          let(:submit_button) { { continue_button: "Continue" } }
          let(:transaction_type) { create(:transaction_type, :pension) }
          let(:applicant) { create(:applicant, :not_employed) }
          let(:legal_aid_application) do
            create(:legal_aid_application, applicant:, transaction_types: [transaction_type])
          end

          it "redirects to next page" do
            expect(subject).to redirect_to(providers_legal_aid_application_means_identify_types_of_income_path(legal_aid_application))
          end

          context "when application is using bank upload journey" do
            before { allow_any_instance_of(LegalAidApplication).to receive(:uploading_bank_statements?).and_return(true) }

            it "redirects to the receives state benefit page" do
              expect(subject).to redirect_to(providers_legal_aid_application_means_receives_state_benefits_path(legal_aid_application))
            end
          end
        end
      end

      context "Save as draft button pressed" do
        let(:submit_button) { { draft_button: "Save as draft" } }

        it "redirects provider to provider's applications page" do
          subject
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end

        it "sets the application as draft" do
          subject
          expect(legal_aid_application.reload).to be_draft
        end
      end
    end
  end
end
