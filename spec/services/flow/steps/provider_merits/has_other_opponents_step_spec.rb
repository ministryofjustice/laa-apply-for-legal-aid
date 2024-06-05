require "rails_helper"

RSpec.describe Flow::Steps::ProviderMerits::HasOtherOpponentsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_has_other_opponent_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application, has_other_opponent) }

    context "when has_other_opponent is true" do
      let(:has_other_opponent) { true }

      it { is_expected.to eq :opponent_types }
    end

    context "when has_other_opponent is false" do
      let(:has_other_opponent) { false }

      before do
        allow(Flow::MeritsLoop).to receive(:forward_flow).and_return(:merits_task_lists)
      end

      it { is_expected.to eq :merits_task_lists }
    end
  end
end
