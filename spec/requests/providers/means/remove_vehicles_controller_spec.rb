require "rails_helper"

RSpec.describe Providers::Means::RemoveVehiclesController do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:vehicle) { create(:vehicle, legal_aid_application:) }
  let(:login) { login_as legal_aid_application.provider }
  let(:extra_vehicle_count) { 0 }

  before do
    create_list(:vehicle, extra_vehicle_count, legal_aid_application:)
    login
    request
  end

  describe "GET /providers/:application_id/means/remove_vehicles/:vehicle_id" do
    let(:request) { get providers_legal_aid_application_means_remove_vehicle_path(legal_aid_application, vehicle) }

    it "returns http success" do
      expect(response).to have_http_status(:ok)
    end

    context "when the provider is not authenticated" do
      let(:login) { nil }

      it_behaves_like "a provider not authenticated"
    end
  end

  describe "PATCH /providers/:application_id/means/remove_vehicles/:vehicle_id" do
    let(:request) { patch providers_legal_aid_application_means_remove_vehicle_path(legal_aid_application, vehicle), params: }

    let(:params) do
      {
        binary_choice_form: {
          remove_vehicle:,
        },
      }
    end

    context "when the provider chose yes" do
      let(:remove_vehicle) { "true" }

      context "and no vehicles remain after deletion" do
        it "redirects to the vehicles page" do
          expect(response).to redirect_to(providers_legal_aid_application_means_vehicle_path(legal_aid_application))
        end

        it { expect(legal_aid_application.vehicles.count).to eq 0 }

        it "resets the own_vehicle value" do
          # this prevents the 'yes' checkbox being selected when the provider returns to the page
          expect(legal_aid_application.own_vehicle?).to be false
        end
      end

      context "and vehicles remain after the deletion" do
        let(:extra_vehicle_count) { 2 }

        it "redirects to the has_other_vehicles page" do
          expect(response).to redirect_to(providers_legal_aid_application_means_add_other_vehicles_path(legal_aid_application))
        end
      end
    end

    context "when the provider chose no" do
      let(:remove_vehicle) { "false" }

      it "redirects to the has other vehicles page" do
        expect(response).to redirect_to(providers_legal_aid_application_means_add_other_vehicles_path(legal_aid_application))
      end
    end

    context "when the provider choose nothing" do
      let(:params) { nil }

      it "show errors" do
        expect(response.body).to include("Select yes if you want to remove this vehicle from the application.")
      end
    end
  end
end
