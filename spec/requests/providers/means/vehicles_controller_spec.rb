require "rails_helper"

RSpec.describe Providers::Means::VehiclesController do
  let(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }
  let(:login) { login_as legal_aid_application.provider }

  before { login }

  describe "GET /providers/applications/:legal_aid_application_id/means/vehicle" do
    subject(:request) { get providers_legal_aid_application_means_vehicle_path(legal_aid_application) }

    before { request }

    it "renders successfully" do
      expect(response).to have_http_status(:ok)
    end

    context "when the provider is not authenticated" do
      let(:login) { nil }

      it_behaves_like "a provider not authenticated"
    end

    context "when the application has no partner" do
      before { login }

      it "shows the correct content" do
        expect(response.body).to include(I18n.t("providers.means.vehicles.show.heading", individual: I18n.t("generic.client")))
      end
    end

    context "when the application has a partner with no contrary interest" do
      let(:legal_aid_application) { create(:legal_aid_application, :with_applicant_and_partner) }

      before { login }

      it "shows the correct content" do
        expect(response.body).to include(I18n.t("providers.means.vehicles.show.heading", individual: I18n.t("generic.client_or_partner")))
      end
    end
  end

  describe "PATCH /providers/applications/:legal_aid_application_id/means/vehicle" do
    subject(:patch_request) do
      patch(
        providers_legal_aid_application_means_vehicle_path(legal_aid_application),
        params:,
      )
    end

    let(:own_vehicle) { nil }
    let(:params) do
      { legal_aid_application: { own_vehicle: } }
    end

    it "renders successfully" do
      patch_request
      expect(response).to have_http_status(:ok)
    end

    it "displays error" do
      patch_request
      expect(response.body).to include("govuk-error-summary")
    end

    context "when the provider is not authenticated" do
      let(:login) { nil }

      before { patch_request }

      it_behaves_like "a provider not authenticated"
    end

    context 'with option "true"' do
      let(:own_vehicle) { "true" }

      it "sets own_vehicle to true" do
        expect { patch_request }.to change { legal_aid_application.reload.own_vehicle }.to(true)
      end

      it "redirects to the next page" do
        patch_request
        expect(response).to have_http_status(:redirect)
      end

      context "when checking answers" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_passported_state_machine, :checking_passported_answers) }

        it "redirects to next page" do
          patch_request
          expect(response).to have_http_status(:redirect)
        end
      end
    end

    context 'when submitted with option "false"' do
      let(:own_vehicle) { "false" }

      it "sets own_vehicle to false" do
        expect { patch_request }.to change { legal_aid_application.reload.own_vehicle }.to(false)
      end

      it "redirects to next page" do
        patch_request
        expect(response).to have_http_status(:redirect)
      end

      context "and existing vehicle" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_vehicle, :passported) }

        it "redirects to next page" do
          patch_request
          expect(response).to have_http_status(:redirect)
        end
      end

      context "when checking answers" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_non_passported_state_machine, :checking_non_passported_means) }

        it "redirects to next page" do
          patch_request
          expect(response).to have_http_status(:redirect)
        end
      end

      context "when checking passported answers" do
        let(:legal_aid_application) { create(:legal_aid_application, :with_passported_state_machine, :checking_passported_answers) }

        it "redirects to next page" do
          patch_request
          expect(response).to have_http_status(:redirect)
        end
      end
    end
  end
end
