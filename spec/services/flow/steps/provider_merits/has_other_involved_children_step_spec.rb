require "rails_helper"

RSpec.describe Flow::Steps::ProviderMerits::HasOtherInvolvedChildrenStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_has_other_involved_children_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application, has_other_involved_child) }

    context "when has_other_involved_child is true" do
      let(:has_other_involved_child) { true }

      it { is_expected.to eq :involved_children }
    end

    context "when has_other_involved_child is false" do
      before do
        allow(Flow::MeritsLoop).to receive(:forward_flow).and_return(:merits_task_lists)
      end

      let(:has_other_involved_child) { false }

      it { is_expected.to eq :merits_task_lists }
    end
  end
end
