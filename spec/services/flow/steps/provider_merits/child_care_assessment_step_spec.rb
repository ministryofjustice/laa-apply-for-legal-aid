require "rails_helper"

RSpec.describe Flow::Steps::ProviderMerits::ChildCareAssessmentStep, type: :request do
  before do
    allow(legal_aid_application).to receive(:provider_step_params).and_return({ "merits_task_list_id" => proceeding.id })
    allow(Flow::MeritsLoop).to receive(:forward_flow).and_return(:fake_next_step)
  end

  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:proceeding) { create(:proceeding, :pbm32, legal_aid_application:) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_merits_task_list_child_care_assessment_path(proceeding) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    context "when assessed is true" do
      before { create(:child_care_assessment, assessed: true, proceeding:) }

      it { is_expected.to eq :child_care_assessment_results }
    end

    context "when assessed is false" do
      before { create(:child_care_assessment, assessed: false, proceeding:) }

      it { is_expected.to eq :fake_next_step }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers.call(legal_aid_application) }

    context "when assessed is true" do
      before { create(:child_care_assessment, assessed: true, proceeding:) }

      it { is_expected.to eq :child_care_assessment_results }
    end

    context "when assessed is false" do
      before { create(:child_care_assessment, assessed: false, proceeding:) }

      it { is_expected.to eq :check_merits_answers }
    end
  end
end
