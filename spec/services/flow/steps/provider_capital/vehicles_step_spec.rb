require "rails_helper"

RSpec.describe Flow::Steps::ProviderCapital::VehiclesStep, type: :request do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application, own_vehicle:) }
  let(:own_vehicle) { true }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_means_vehicle_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    context "when the user selects that the applicant owns a vehicle" do
      it { is_expected.to eq :vehicle_details }
    end

    context "when the user selects that the applicant does not own a vehicle and they are not uploading bank statements" do
      before { allow(legal_aid_application).to receive(:uploading_bank_statements?).and_return(false) }

      let(:own_vehicle) { false }

      it { is_expected.to eq :applicant_bank_accounts }
    end

    context "when the user selects that the applicant does not own a vehicle and they are uploading bank statements" do
      before { allow(legal_aid_application).to receive(:uploading_bank_statements?).and_return(true) }

      let(:own_vehicle) { false }

      it { is_expected.to eq :offline_accounts }
    end
  end

  describe "#carry_on_sub_flow" do
    subject { described_class.carry_on_sub_flow.call(legal_aid_application) }

    context "when the user selects that the applicant owns a vehicle" do
      it { is_expected.to be true }
    end

    context "when the user selects that the applicant does not own a vehicle" do
      let(:own_vehicle) { false }

      it { is_expected.to be false }
    end
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
