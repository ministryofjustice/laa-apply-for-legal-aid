require "rails_helper"

RSpec.describe Flow::Steps::ProviderMerits::RemoveOpponentStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:opponent) { create(:opponent, legal_aid_application:) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application, opponent) }

    it { is_expected.to eq providers_legal_aid_application_remove_opponent_path(legal_aid_application, opponent) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    context "when at least one opponent remains on the application" do
      before { create(:opponent, legal_aid_application:) }

      it { is_expected.to eq :has_other_opponents }
    end

    context "when no opponents remain on the application" do
      it { is_expected.to eq :opponent_types }
    end
  end
end
