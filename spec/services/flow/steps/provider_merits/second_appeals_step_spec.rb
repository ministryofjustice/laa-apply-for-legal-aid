require "rails_helper"

RSpec.describe Flow::Steps::ProviderMerits::SecondAppealsStep, type: :request do
  let(:legal_aid_application) do
    create(:legal_aid_application,
           appeal: create(:appeal, second_appeal:))
  end

  before do
    allow(Flow::MeritsLoop).to receive(:forward_flow).and_return(:merits_task_lists)
  end

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    let(:second_appeal) { true }

    it { is_expected.to eq providers_legal_aid_application_second_appeal_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    context "when second_appeal is true" do
      let(:second_appeal) { true }

      # TODO: AP-5531/5532 - should go to question 3 "Which court will the second appeal be heard in?"
      it { is_expected.to eq :merits_task_lists }
    end

    context "when second_appeal is false" do
      let(:second_appeal) { false }

      it { is_expected.to eq :original_judge_levels }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers.call(legal_aid_application) }

    context "when second_appeal is true" do
      let(:second_appeal) { true }

      # TODO: AP-5531/5532 - should go to question 3 "Which court will the second appeal be heard in?"
      it { is_expected.to eq :check_merits_answers }
    end

    context "when second_appeal is false" do
      let(:second_appeal) { false }

      it { is_expected.to eq :original_judge_levels }
    end
  end
end
