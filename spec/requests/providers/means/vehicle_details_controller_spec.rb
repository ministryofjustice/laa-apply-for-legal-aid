require "rails_helper"

RSpec.describe Providers::Means::VehicleDetailsController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_vehicle) }
  let(:login) { login_as legal_aid_application.provider }

  before { login }

  describe "GET /providers/applications/:legal_aid_application_id/means/vehicle_details" do
    subject(:get_vehicle_details) { get providers_legal_aid_application_means_vehicle_details_path(legal_aid_application) }

    it "renders successfully" do
      get_vehicle_details
      expect(response).to have_http_status(:ok)
    end

    context "when the provider is not authenticated" do
      let(:login) { nil }

      before { get_vehicle_details }

      it_behaves_like "a provider not authenticated"
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/means/vehicle_details" do
    subject(:patch_vehicle_details) do
      patch(
        providers_legal_aid_application_means_vehicle_details_path(legal_aid_application),
        params: params.merge(submit_button),
      )
    end

    let(:submit_button) { {} }
    let(:estimated_value) { nil }
    let(:more_than_three_years_old) { nil }
    let(:payment_remaining) { nil }
    let(:payments_remain) { nil }
    let(:used_regularly) { nil }
    let(:params) do
      {
        vehicle: {
          estimated_value:,
          more_than_three_years_old:,
          payment_remaining:,
          payments_remain:,
          used_regularly:,
        },
      }
    end

    context "when the provider is not authenticated" do
      let(:login) { nil }

      before { patch_vehicle_details }

      it_behaves_like "a provider not authenticated"
    end

    context "when submitted with no parameters populated" do
      it "renders successfully" do
        patch_vehicle_details
        expect(response).to have_http_status(:ok)
      end

      it "displays error" do
        patch_vehicle_details
        expect(response.body).to include("govuk-error-summary")
      end
    end

    context "when submitted with valid parameters" do
      let(:estimated_value) { 3000 }
      let(:more_than_three_years_old) { true }
      let(:payments_remain) { false }
      let(:payment_remaining) { nil }
      let(:used_regularly) { true }

      it "updates vehicle" do
        patch_vehicle_details
        expect(legal_aid_application.vehicle.reload).to have_attributes(
          {
            estimated_value: 3000,
            more_than_three_years_old: true,
            payment_remaining: 0,
            used_regularly: true,
          },
        )
      end

      context "when the application is non-passported" do
        it "redirects to next step" do
          patch_vehicle_details
          expect(response).to redirect_to(providers_legal_aid_application_applicant_bank_account_path(legal_aid_application))
        end
      end

      context "when the application is passported" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_vehicle, :passported) }

        it "redirects to next step" do
          patch_vehicle_details
          expect(response).to redirect_to(providers_legal_aid_application_offline_account_path(legal_aid_application))
        end
      end

      context "when the Form is submitted using Save as draft button" do
        let(:submit_button) { { draft_button: "Save as draft" } }

        it "redirects provider to provider's applications page" do
          patch_vehicle_details
          expect(response).to redirect_to(providers_legal_aid_applications_path)
        end

        it "sets the application as draft" do
          expect { patch_vehicle_details }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
        end
      end

      context "and checking non passported answers" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_non_passported_state_machine, :checking_non_passported_means) }

        it "redirects to check capital answers page" do
          patch_vehicle_details
          expect(response).to redirect_to(providers_legal_aid_application_check_capital_answers_path(legal_aid_application))
        end
      end

      context "and checking passported answers" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_passported_state_machine, :checking_passported_answers) }

        it "redirects to passported check answers page" do
          patch_vehicle_details
          expect(response).to redirect_to(providers_legal_aid_application_check_passported_answers_path(legal_aid_application))
        end
      end
    end
  end
end
