require "rails_helper"

RSpec.describe Flow::Steps::ProviderCapital::SavingsAndInvestmentsStep, type: :request do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application) }
  let(:own_capital?) { true }
  let(:checking_answers?) { true }

  before do
    allow(legal_aid_application).to receive_messages(own_capital?: own_capital?,
                                                     checking_answers?: checking_answers?)
  end

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_means_savings_and_investment_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    context "when own_capital and checking answers are both true" do
      it { is_expected.to eq :restrictions }
    end

    context "when only one value is true" do
      let(:checking_answers?) { false }

      it { is_expected.to eq :other_assets }
    end

    context "when neither value is true" do
      let(:own_capital?) { false }
      let(:checking_answers?) { false }

      it { is_expected.to eq :other_assets }
    end
  end

  describe "#carry_on_sub_flow" do
    subject { described_class.carry_on_sub_flow.call(legal_aid_application) }

    context "when the user selects that the applicant owns capital?" do
      it { is_expected.to be true }
    end

    context "when the user selects that the applicant does not own capital" do
      let(:own_capital?) { false }

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
