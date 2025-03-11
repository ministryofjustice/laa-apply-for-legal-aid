require "rails_helper"

RSpec.describe Flow::Steps::ProviderCapital::OwnHomesStep, type: :request do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application, own_home:) }
  let(:own_home) { "mortgage" }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_means_own_home_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    context "when the user selects that the applicant owns their home" do
      it { is_expected.to eq :property_details }
    end

    context "when the user selects that the applicant does not own their home" do
      let(:own_home) { "no" }

      context "and they have previously said there is a vehicle" do
        let(:legal_aid_application) { create(:legal_aid_application, own_home:) }

        before { create(:vehicle, legal_aid_application:) }

        it { is_expected.to eq :add_other_vehicles }
      end

      context "and they have previously said there is no vehicle" do
        it { is_expected.to eq :vehicles }
      end
    end
  end

  describe "#carry_on_sub_flow" do
    subject { described_class.carry_on_sub_flow.call(legal_aid_application) }

    context "when the user selects that the applicant owns their home" do
      it { is_expected.to be true }
    end

    context "when the user selects that the applicant does not own their home" do
      let(:own_home) { "no" }

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
