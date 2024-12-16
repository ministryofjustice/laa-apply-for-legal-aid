require "rails_helper"

RSpec.describe Flow::Steps::ProviderMerits::OriginalJudgeLevelsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application, appeal:) }
  let(:appeal) { create(:appeal, original_judge_level:) }

  before do
    allow(Flow::MeritsLoop).to receive(:forward_flow).and_return(:merits_task_lists)
  end

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    let(:original_judge_level) { nil }

    it { is_expected.to eq providers_legal_aid_application_original_judge_level_path(legal_aid_application) }
  end

  describe "#forward" do
    subject(:call) { described_class.forward.call(legal_aid_application) }

    context "when original_judge_level in recorder_circuit_judge high_court_judge" do
      let(:original_judge_level) { "recorder_circuit_judge" }

      it { is_expected.to eq :first_appeal_court_types }
    end

    context "when original_judge_level in high_court_judge" do
      let(:original_judge_level) { "high_court_judge" }

      it { is_expected.to eq :first_appeal_court_types }
    end

    context "when original_judge_level is other string value" do
      let(:original_judge_level) { "foobar" }

      it "goes to next question" do
        expect(call).to eq :merits_task_lists
      end
    end

    context "when original_judge_level is nil" do
      let(:original_judge_level) { nil }

      it "goes to next question" do
        expect(call).to eq :merits_task_lists
      end
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers.call(legal_aid_application) }

    context "when original_judge_level in recorder_circuit_judge high_court_judge" do
      let(:original_judge_level) { "recorder_circuit_judge" }

      it { is_expected.to eq :first_appeal_court_types }
    end

    context "when original_judge_level in high_court_judge" do
      let(:original_judge_level) { "high_court_judge" }

      it { is_expected.to eq :first_appeal_court_types }
    end

    context "when original_judge_level is other string value" do
      let(:original_judge_level) { "foobar" }

      it { is_expected.to eq :check_merits_answers }
    end

    context "when original_judge_level is nil" do
      let(:original_judge_level) { nil }

      it { is_expected.to eq :check_merits_answers }
    end
  end
end
