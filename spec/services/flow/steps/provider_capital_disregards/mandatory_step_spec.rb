require "rails_helper"

RSpec.describe Flow::Steps::ProviderCapitalDisregards::MandatoryStep, type: :request do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application) }

  let(:passported?) { nil }
  let(:provider_checking_or_checked_citizens_means_answers?) { nil }
  let(:mandatory_disregard) { nil }

  before do
    allow(legal_aid_application).to receive_messages(passported?: passported?)
  end

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_means_capital_disregards_mandatory_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application, mandatory_disregard) }

    context "when one or more disregards are chosen" do
      let(:legal_aid_application) { build_stubbed(:legal_aid_application, mandatory_capital_disregards: [mandatory_disregard]) }
      let(:mandatory_disregard) { create(:capital_disregard, :mandatory) }

      it { is_expected.to eq :capital_disregards_add_details }
    end

    context "when no disregards are chosen" do
      it { is_expected.to eq :capital_disregards_discretionary }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers.call(legal_aid_application, mandatory_disregard) }

    before do
      allow(legal_aid_application).to receive(:passported?)
                                        .and_return(passported?)
    end

    context "when one or more disregards are chosen" do
      let(:legal_aid_application) { build_stubbed(:legal_aid_application, mandatory_capital_disregards: [mandatory_disregard]) }
      let(:mandatory_disregard) { create(:capital_disregard, :mandatory) }

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
