require "rails_helper"

RSpec.describe Flow::Steps::ProviderCapitalDisregards::DiscretionaryStep, type: :request do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application) }

  let(:passported?) { nil }
  let(:provider_checking_or_checked_citizens_means_answers?) { nil }
  let(:discretionary_disregard) { nil }

  before do
    allow(legal_aid_application).to receive_messages(passported?: passported?)
  end

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_means_capital_disregards_discretionary_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application, discretionary_disregard) }

    context "when no disregards are chosen" do
      context "when passported is true" do
        let(:passported?) { true }

        it { is_expected.to eq :check_passported_answers }
      end

      context "when passported is not true" do
        it { is_expected.to eq :check_capital_answers }
      end
    end

    context "when one or more disregards are chosen" do
      let(:legal_aid_application) { build_stubbed(:legal_aid_application, discretionary_capital_disregards: [discretionary_disregard]) }
      let(:discretionary_disregard) { create(:capital_disregard, :discretionary) }

      it { is_expected.to eq :capital_disregards_add_details }
    end

    context "when passported is true" do
      let(:passported?) { true }

      it { is_expected.to eq :check_passported_answers }
    end

    context "when passported is not true" do
      it { is_expected.to eq :check_capital_answers }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers.call(legal_aid_application, discretionary_disregard) }

    before do
      allow(legal_aid_application).to receive(:passported?)
                                        .and_return(passported?)
    end

    context "when one or more disregards are chosen" do
      let(:legal_aid_application) { build_stubbed(:legal_aid_application, discretionary_capital_disregards: [discretionary_disregard]) }
      let(:discretionary_disregard) { create(:capital_disregard, :discretionary) }

      it { is_expected.to eq :capital_disregards_add_details }
    end

    context "when the application is non passported" do
      let(:passported?) { false }

      it { is_expected.to eq :check_capital_answers }
    end

    context "when the application is passported" do
      let(:passported?) { true }

      it { is_expected.to eq :check_passported_answers }
    end
  end
end
