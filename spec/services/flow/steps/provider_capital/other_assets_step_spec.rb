require "rails_helper"

RSpec.describe Flow::Steps::ProviderCapital::OtherAssetsStep, type: :request do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application) }
  let(:own_capital?) { nil }
  let(:capture_policy_disregards?) { nil }
  let(:passported?) { nil }
  let(:other_assets?) { nil }

  before do
    allow(legal_aid_application).to receive_messages(own_capital?: own_capital?,
                                                     capture_policy_disregards?: capture_policy_disregards?,
                                                     passported?: passported?,
                                                     other_assets?: other_assets?)
  end

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_means_other_assets_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    context "when own_capital is true" do
      let(:own_capital?) { true }

      it { is_expected.to eq :restrictions }
    end

    context "when capture_policy_disregards is true" do
      let(:capture_policy_disregards?) { true }

      it { is_expected.to eq :capital_disregards_mandatory }
    end

    context "when passported is true" do
      let(:passported?) { true }

      it { is_expected.to eq :check_passported_answers }
    end

    context "when none of those are true" do
      it { is_expected.to eq :check_capital_answers }
    end
  end

  describe "#carry_on_sub_flow" do
    subject { described_class.carry_on_sub_flow.call(legal_aid_application) }

    context "when the user selects that the applicant has other assets" do
      let(:other_assets?) { true }

      it { is_expected.to be true }
    end

    context "when the user selects that the applicant does not have other assets" do
      let(:other_assets?) { false }

      it { is_expected.to be false }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers.call(legal_aid_application) }

    before do
      allow(legal_aid_application).to receive(:checking_non_passported_means?).and_return(checking_non_passported_means?)
    end

    context "when the application is checking_non_passported_means" do
      let(:checking_non_passported_means?) { true }

      it { is_expected.to eq :check_capital_answers }
    end

    context "when the application is not checking_non_passported_means" do
      let(:checking_non_passported_means?) { nil }

      it { is_expected.to eq :check_passported_answers }
    end
  end
end
