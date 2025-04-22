require "rails_helper"

RSpec.describe Flow::Steps::ProviderMerits::CourtOrderCopiesStep, type: :request do
  let(:legal_aid_application) { build_stubbed(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_court_order_copy_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    before do
      allow(Flow::MeritsLoop).to receive(:forward_flow).and_return(:merits_task_lists)
    end

    it { is_expected.to eq :merits_task_lists }
  end

  describe "#check_answers" do
    subject { described_class.check_answers.call(legal_aid_application, copy_of_court_order) }

    context "when `copy_of_court_order` is `true`" do
      let(:copy_of_court_order) { true }

      it { is_expected.to eq(:uploaded_evidence_collections) }
    end

    context "when `copy_of_court_order` is `false`" do
      let(:copy_of_court_order) { false }

      it { is_expected.to eq :check_merits_answers }
    end
  end
end
