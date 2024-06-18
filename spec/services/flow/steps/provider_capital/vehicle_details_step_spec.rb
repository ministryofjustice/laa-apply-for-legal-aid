require "rails_helper"

RSpec.describe Flow::Steps::ProviderCapital::VehicleDetailsStep, type: :request do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq new_providers_legal_aid_application_means_vehicle_detail_path(legal_aid_application) }
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
