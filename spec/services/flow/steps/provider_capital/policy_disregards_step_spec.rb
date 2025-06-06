require "rails_helper"

RSpec.describe Flow::Steps::ProviderCapital::PolicyDisregardsStep, type: :request do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application) }
  let(:passported?) { nil }
  let(:provider_checking_or_checked_citizens_means_answers?) { nil }

  before do
    allow(legal_aid_application).to receive_messages(passported?: passported?,
                                                     provider_checking_or_checked_citizens_means_answers?: provider_checking_or_checked_citizens_means_answers?)
  end

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_means_policy_disregards_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward }

    it { is_expected.to eq :capital_disregards_discretionary }
  end

  describe "#check_answers" do
    subject { described_class.check_answers.call(legal_aid_application) }

    before do
      allow(legal_aid_application).to receive(:provider_checking_or_checked_citizens_means_answers?)
                                        .and_return(provider_checking_or_checked_citizens_means_answers?)
    end

    context "when the application is provider_checking_or_checked_citizens_means_answers" do
      let(:provider_checking_or_checked_citizens_means_answers?) { true }

      it { is_expected.to eq :check_capital_answers }
    end

    context "when the application is not provider_checking_or_checked_citizens_means_answers" do
      let(:provider_checking_or_checked_citizens_means_answers?) { nil }

      it { is_expected.to eq :check_passported_answers }
    end
  end
end
