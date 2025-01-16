require "rails_helper"

RSpec.describe Flow::Steps::ProviderMerits::ChildCareAssessmentResultStep, type: :request do
  before do
    allow(legal_aid_application).to receive(:provider_step_params).and_return({ "merits_task_list_id" => proceeding.id })
    allow(Flow::MeritsLoop).to receive(:forward_flow).and_return(:fake_next_step)
  end

  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:proceeding) { create(:proceeding, :pbm32, legal_aid_application:) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_merits_task_list_child_care_assessment_result_path(proceeding) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    it { is_expected.to eq :fake_next_step }
  end

  describe "#check_answers" do
    subject { described_class.check_answers }

    it { is_expected.to eq :check_merits_answers }
  end
end
