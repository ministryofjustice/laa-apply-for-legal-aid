require "rails_helper"

RSpec.describe Flow::Steps::ProviderMerits::OriginalJudgeLevelsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  before do
    allow(Flow::MeritsLoop).to receive(:forward_flow).and_return(:merits_task_lists)
  end

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_original_judge_level_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    # TODO: AP-5531/5532 - should go to question 4 "Which court will the appeal be heard in?" or Next question
    it { is_expected.to eq :merits_task_lists }
  end

  describe "#check_answers" do
    subject { described_class.check_answers }

    it { is_expected.to eq :check_merits_answers }
  end
end
