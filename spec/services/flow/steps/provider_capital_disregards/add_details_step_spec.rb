require "rails_helper"

RSpec.describe Flow::Steps::ProviderCapitalDisregards::AddDetailsStep, type: :request do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application) }
  let(:disregard) { build_stubbed(:capital_disregard, legal_aid_application:) }

  let(:passported?) { nil }
  let(:provider_checking_or_checked_citizens_means_answers?) { nil }

  before do
    allow(legal_aid_application).to receive_messages(passported?: passported?)
  end

  describe "#path" do
    subject { described_class.path.call(legal_aid_application, disregard) }

    it { is_expected.to eql providers_legal_aid_application_means_capital_disregards_add_detail_path(legal_aid_application, disregard) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application, disregard) }

    context "when disregard is present" do
      it { is_expected.to eq :capital_disregards_add_details }
    end

    context "when disregard is not present" do
      let(:disregard) { nil }

      context "and the user has added details for all mandatory_capital_disregards" do
        before do
          allow(legal_aid_application).to receive(:mandatory_capital_disregards).and_return(true)
          allow(legal_aid_application.discretionary_capital_disregards).to receive(:empty?).and_return(true)
        end

        it { is_expected.to eq :capital_disregards_discretionary }
      end

      context "and the user has added details for all discretionary_capital_disregards" do
        before do
          allow(legal_aid_application.discretionary_capital_disregards).to receive(:empty?).and_return(false)
        end

        context "and the application is passported" do
          let(:passported?) { true }

          it { is_expected.to eq :check_passported_answers }
        end

        context "and the application is non_passported" do
          let(:passported?) { false }

          it { is_expected.to eq :check_capital_answers }
        end
      end
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers.call(legal_aid_application, disregard) }

    before do
      allow(legal_aid_application).to receive(:passported?)
                                        .and_return(passported?)
    end

    context "when disregard is present" do
      it { is_expected.to eq :capital_disregards_add_details }
    end

    context "when disregard is not present" do
      let(:disregard) { nil }

      context "and the application is passported" do
        let(:passported?) { true }

        it { is_expected.to eq :check_passported_answers }
      end

      context "and the application is non passported" do
        let(:passported?) { false }

        it { is_expected.to eq :check_capital_answers }
      end
    end
  end
end
