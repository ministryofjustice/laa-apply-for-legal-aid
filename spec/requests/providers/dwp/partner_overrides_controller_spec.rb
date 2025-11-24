require "rails_helper"

RSpec.describe Providers::DWP::PartnerOverridesController do
  let(:application) { create(:legal_aid_application, :with_proceedings, :at_checking_applicant_details, :with_applicant_and_partner) }

  describe "GET /providers/applications/:legal_aid_application_id/dwp/dwp-override" do
    subject(:get_request) { get providers_legal_aid_application_dwp_partner_override_path(application) }

    context "when the provider is not authenticated" do
      before { get_request }

      it_behaves_like "a provider not authenticated"
    end

    context "when the provider is authenticated" do
      before do
        login_as application.provider
      end

      it "returns success" do
        get_request
        expect(response).to be_successful
      end

      it "displays the correct options" do
        get_request
        expect(page)
          .to have_css(".govuk-radios label", text: "On their own")
          .and have_css(".govuk-radios label", text: "With a partner")
      end

      it "updates confirm_dwp_result to false" do
        expect { get_request }
          .to change { application.reload.dwp_result_confirmed }
          .from(nil)
          .to false
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/dwp/dwp-override" do
    context "when submitting with the Continue button" do
      subject(:patch_request) { patch providers_legal_aid_application_dwp_partner_override_path(application), params: }

      let(:params) do
        {
          continue_button: "Continue",
        }
      end

      before do
        login_as application.provider
      end

      context "when the joint-benefit-with-partner option is selected" do
        let(:params) do
          {
            continue_button: "Continue",
            partner: {
              confirm_dwp_result: "joint_benefit_with_partner",
            },
          }
        end

        context "when the status is already overriding_dwp_result" do
          before { application.override_dwp_result! }

          it { expect { patch_request }.not_to change { application.reload.state }.from("overriding_dwp_result") }
        end

        context "when the state is not already overriding_dwp_result" do
          it "sets the application state to overriding overriding_dwp_result result" do
            expect { patch_request }.to change { application.reload.state }.to("overriding_dwp_result")
          end
        end

        it "redirects to the next page" do
          patch_request
          expect(response).to redirect_to providers_legal_aid_application_check_client_details_path(application)
        end
      end

      context "when the non-joint-benefit option is selected" do
        let(:application) { create(:legal_aid_application, :with_applicant_and_partner, :with_proceedings, :at_checking_applicant_details) }
        let(:partner) { application.partner }

        let(:params) do
          {
            continue_button: "Continue",
            partner: {
              confirm_dwp_result: "benefit_received",
            },
          }
        end

        context "when the status is already overriding_dwp_result" do
          before { application.override_dwp_result! }

          it { expect { patch_request }.not_to change { application.reload.state } }
        end

        context "when the state is not already override_dwp_result" do
          it "sets the application state to overriding DWP result" do
            expect { patch_request }.to change { application.reload.state }.to("overriding_dwp_result")
          end
        end

        it "redirects to the next page" do
          patch_request
          expect(response).to redirect_to providers_legal_aid_application_check_client_details_path(application)
        end

        it "does not update the partner shared benefit field" do
          patch_request
          expect(partner.reload.shared_benefit_with_applicant).to be false
        end
      end

      context "when no option is selected" do
        it "displays an error" do
          patch_request
          expect(response.body).to include("Select if your client gets the passporting benefit on their own or with a partner")
        end
      end
    end

    context "when submitting with the Save As Draft button" do
      subject(:patch_request) { patch providers_legal_aid_application_dwp_partner_override_path(application), params: }

      let(:params) do
        {
          draft_button: "Save as draft",
        }
      end

      before do
        login_as application.provider
      end

      it "redirects provider to provider's applications page" do
        patch_request
        expect(response).to redirect_to(in_progress_providers_legal_aid_applications_path)
      end

      it "sets the application as draft" do
        patch_request
        expect(application.reload).to be_draft
      end
    end
  end
end
