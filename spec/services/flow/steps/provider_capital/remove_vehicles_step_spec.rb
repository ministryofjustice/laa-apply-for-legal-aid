require "rails_helper"

RSpec.describe Flow::Steps::ProviderCapital::RemoveVehiclesStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:vehicle) { create(:vehicle, legal_aid_application:) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application, vehicle) }

    it { is_expected.to eq providers_legal_aid_application_means_remove_vehicle_path(legal_aid_application, vehicle) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application, vehicles_remain) }

    context "when vehicles remain on the application" do
      let(:vehicles_remain) { true }

      it { is_expected.to eq :add_other_vehicles }
    end

    context "when no vehicles remain on the application" do
      let(:vehicles_remain) { false }

      it { is_expected.to eq :vehicles }
    end
  end
end
