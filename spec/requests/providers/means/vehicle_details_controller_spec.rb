require "rails_helper"

RSpec.describe Providers::Means::VehicleDetailsController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_vehicle, :with_applicant_and_partner) }
  let(:login) { login_as legal_aid_application.provider }

  before { login }

  describe "new GET /providers/applications/:legal_aid_application_id/means/vehicle_details" do
    subject(:get_vehicle_details) { get new_providers_legal_aid_application_means_vehicle_detail_path(legal_aid_application) }

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

  describe "show GET /providers/applications/:legal_aid_application_id/means/vehicle_details/:vehicle_id" do
    subject(:get_vehicle_details) { get providers_legal_aid_application_means_vehicle_detail_path(legal_aid_application, vehicle) }

    let(:vehicle) { create(:vehicle, legal_aid_application:) }

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
        providers_legal_aid_application_means_vehicle_detail_path(legal_aid_application, vehicle),
        params: params.merge(submit_button),
      )
    end

    let(:vehicle) { create(:vehicle, legal_aid_application:) }
    let(:submit_button) { {} }
    let(:owner) { nil }
    let(:estimated_value) { nil }
    let(:more_than_three_years_old) { nil }
    let(:payment_remaining) { nil }
    let(:payments_remain) { nil }
    let(:used_regularly) { nil }
    let(:params) do
      {
        vehicle: {
          owner:,
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
      let(:owner) { "client" }
      let(:estimated_value) { 3000 }
      let(:more_than_three_years_old) { true }
      let(:payments_remain) { false }
      let(:payment_remaining) { nil }
      let(:used_regularly) { true }

      it "updates vehicle" do
        patch_vehicle_details
        expect(vehicle.reload).to have_attributes(
          {
            owner: "client",
            estimated_value: 3000,
            more_than_three_years_old: true,
            payment_remaining: 0,
            used_regularly: true,
          },
        )
      end

      context "and the application is non-passported" do
        it "redirects to next step" do
          patch_vehicle_details
          expect(response).to have_http_status(:redirect)
        end
      end

      context "and the application is passported" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_vehicle, :passported) }

        it "redirects to next step" do
          patch_vehicle_details
          expect(response).to have_http_status(:redirect)
        end
      end

      context "and the Form is submitted using Save as draft button" do
        let(:submit_button) { { draft_button: "Save as draft" } }

        it "redirects provider to provider's applications page" do
          patch_vehicle_details
          expect(response).to redirect_to(in_progress_providers_legal_aid_applications_path)
        end

        it "sets the application as draft" do
          expect { patch_vehicle_details }.to change { legal_aid_application.reload.draft? }.from(false).to(true)
        end
      end

      context "and the user is checking non passported answers" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_non_passported_state_machine, :checking_non_passported_means) }

        it "redirects to next check_answers page" do
          patch_vehicle_details
          expect(response).to have_http_status(:redirect)
        end
      end

      context "and the user is checking passported answers" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_applicant, :with_passported_state_machine, :checking_passported_answers) }

        it "redirects to next check answers page" do
          patch_vehicle_details
          expect(response).to have_http_status(:redirect)
        end
      end
    end
  end
end
