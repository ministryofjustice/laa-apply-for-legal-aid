require "rails_helper"

RSpec.describe Flow::Steps::ProviderCapital::AddOtherVehiclesStep, type: :request do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_means_add_other_vehicles_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application, add_other_vehicles) }

    let(:add_other_vehicles) { true }

    context "when add_other_vehicles is true" do
      it { is_expected.to eq :vehicle_details }
    end

    context "when add_other_vehicles is false" do
      let(:add_other_vehicles) { false }

      context "and application is non_passported and not uploading bank statements" do
        before { allow(legal_aid_application).to receive(:uploading_bank_statements?).and_return(false) }

        it { is_expected.to eq :applicant_bank_accounts }
      end

      context "and bank statements are being uploaded" do
        before { allow(legal_aid_application).to receive(:uploading_bank_statements?).and_return(true) }

        it { is_expected.to eq :offline_accounts }
      end
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers.call(legal_aid_application, add_other_vehicles) }

    let(:add_other_vehicles) { true }

    context "when add_other_vehicles is true" do
      it { is_expected.to eq :vehicle_details }
    end

    context "when add_other_vehicles is false" do
      let(:add_other_vehicles) { false }

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
end
