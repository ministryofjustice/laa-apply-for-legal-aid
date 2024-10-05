require "rails_helper"

RSpec.describe Flow::Steps::ProviderCapital::VehicleDetailsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application, provider_step_params:) }
  let(:provider_step_params) { {} }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq new_providers_legal_aid_application_means_vehicle_detail_path(legal_aid_application) }

    context "when the user has previously clicked save as draft on the vehicle details page" do
      before { legal_aid_application.vehicles << vehicle }

      let(:vehicle) { create(:vehicle) }
      let(:provider_step_params) { { id: vehicle.id } }

      it { is_expected.to eq providers_legal_aid_application_means_vehicle_detail_path(legal_aid_application, vehicle) }
    end

    context "when a user has somehow stored an invalid vehicle id (BUG AP-5365)" do
      let(:provider_step_params) { { id: "new" } }

      it { is_expected.to eq new_providers_legal_aid_application_means_vehicle_detail_path(legal_aid_application) }
    end
  end

  describe "#forward" do
    subject { described_class.forward }

    it { is_expected.to eq :add_other_vehicles }
  end

  describe "#check_answers" do
    subject { described_class.check_answers.call(legal_aid_application) }

    context "when provider is checking_non_passported_means?" do
      before { allow(legal_aid_application).to receive(:checking_non_passported_means?).and_return(true) }

      it { is_expected.to eq :check_capital_answers }
    end

    context "when provider is not checking_non_passported_means?" do
      before { allow(legal_aid_application).to receive(:checking_non_passported_means?).and_return(false) }

      it { is_expected.to eq :check_passported_answers }
    end
  end
end
