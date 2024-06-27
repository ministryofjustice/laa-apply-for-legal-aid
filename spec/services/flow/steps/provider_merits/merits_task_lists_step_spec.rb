require "rails_helper"

RSpec.describe Flow::Steps::ProviderMerits::MeritsTaskListsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_merits_task_list_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    context "when evidence is required" do
      before do
        allow(legal_aid_application).to receive(:evidence_is_required?).and_return(true)
      end

      it { is_expected.to eq :uploaded_evidence_collections }
    end

    context "when evidence is not required" do
      before do
        allow(legal_aid_application).to receive(:evidence_is_required?).and_return(false)
      end

      it { is_expected.to eq :check_merits_answers }
    end
  end
end
