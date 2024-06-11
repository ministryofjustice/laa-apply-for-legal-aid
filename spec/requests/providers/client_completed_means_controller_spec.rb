require "rails_helper"

RSpec.describe Providers::ClientCompletedMeansController do
  let(:legal_aid_application) { create(:legal_aid_application, applicant:, partner:) }
  let(:applicant) { create(:applicant, :employed, has_partner:) }
  let(:has_partner) { false }
  let(:partner) { nil }
  let(:provider) { legal_aid_application.provider }

  describe "GET /providers/applications/:id/client_completed_means" do
    subject(:get_request) { get providers_legal_aid_application_client_completed_means_path(legal_aid_application) }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as provider
        get_request
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
    subject(:patch_request) { patch providers_legal_aid_application_client_completed_means_path(legal_aid_application), params: params.merge(submit_button) }

    let(:params) { {} }

    context "when the provider is authenticated" do
      before do
        login_as provider
      end

      context "when the continue button is pressed" do
        let(:submit_button) { { continue_button: "Continue" } }

        context "and employment income data was received from HMRC" do
          let(:legal_aid_application) { create(:legal_aid_application, :with_single_employment, applicant:, partner:) }

          it "redirects to the employment income page" do
            patch_request
            expect(response).to redirect_to(providers_legal_aid_application_means_employment_income_path(legal_aid_application))
          end
        end

        context "and an unknown result was obtained from HMRC::StatusAnalyzer" do
          before do
            allow(HMRC::StatusAnalyzer).to receive(:call).with(legal_aid_application).and_return(:xxx)
          end

          it "raises an error" do
            expect { patch_request }.to raise_error RuntimeError, "Unexpected hmrc status :xxx"
          end
        end

        context "and no employment income data was received from HMRC" do
          it "redirects to the no employed income page" do
            patch_request
            expect(response).to redirect_to(providers_legal_aid_application_means_full_employment_details_path(legal_aid_application))
          end
        end

        context "and employment income data for multiple jobs was received from HMRC" do
          let(:legal_aid_application) { create(:legal_aid_application, :with_multiple_employments, applicant:, partner:) }

          it "redirects to the no employed income page" do
            patch_request
            expect(response).to redirect_to(providers_legal_aid_application_means_full_employment_details_path(legal_aid_application))
          end
        end

        context "and transactions exist, and applicant is not employed" do
          let(:submit_button) { { continue_button: "Continue" } }
          let(:transaction_type) { create(:transaction_type, :pension) }
          let(:applicant) { create(:applicant, :not_employed) }
          let(:legal_aid_application) do
            create(:legal_aid_application, applicant:, transaction_types: [transaction_type])
          end

          it "redirects to next page" do
            expect(patch_request).to redirect_to(providers_legal_aid_application_means_identify_types_of_income_path(legal_aid_application))
          end

          context "when application is using bank upload journey" do
            let(:legal_aid_application) { create(:legal_aid_application, :with_client_uploading_bank_statements, applicant:, partner:) }

            it "redirects to the receives state benefit page" do
              expect(patch_request).to redirect_to(providers_legal_aid_application_means_receives_state_benefits_path(legal_aid_application))
            end
          end
        end
      end

      context "when the Save as draft is button pressed" do
        let(:submit_button) { { draft_button: "Save as draft" } }

        it "redirects provider to provider's applications page" do
          patch_request
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end

        it "sets the application as draft" do
          patch_request
          expect(legal_aid_application.reload).to be_draft
        end
      end
    end
  end
end
