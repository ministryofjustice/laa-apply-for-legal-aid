require "rails_helper"

RSpec.describe Flow::Steps::ProviderMerits::FirstAppealCourtTypesStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  before do
    allow(Flow::MeritsLoop).to receive(:forward_flow).and_return(:merits_task_lists)
  end

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_first_appeal_court_type_path(legal_aid_application) }
  end

  describe "#forward" do
    subject(:call) { described_class.forward.call(legal_aid_application) }

    it "goes to next step/question in loop" do
      expect(call).to eq :merits_task_lists
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers }

    it { is_expected.to eq :check_merits_answers }
  end
end
