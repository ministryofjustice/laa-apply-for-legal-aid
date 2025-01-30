require "rails_helper"

RSpec.describe Flow::Steps::ProviderMerits::ChancesOfSuccessStep, type: :request do
  before do
    allow(legal_aid_application).to receive(:provider_step_params).and_return({ "merits_task_list_id" => proceeding.id })
    allow(Flow::MeritsLoop).to receive(:forward_flow).and_return(:merits_task_lists)
  end

  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:proceeding) { create(:proceeding, :da001, legal_aid_application:) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_merits_task_list_chances_of_success_path(proceeding) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    before { create(:chances_of_success, success_likely:, success_prospect_details: "details", proceeding:) }

    context "when chances_of_success is true" do
      let(:success_likely) { true }

      it { is_expected.to eq :merits_task_lists }
    end

    context "when chances_of_success is false" do
      let(:success_likely) { false }

      it { is_expected.to eq :merits_task_lists }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers }

    before { create(:chances_of_success, success_likely:, success_prospect_details: "details", proceeding:) }

    context "when chances_of_success is true" do
      let(:success_likely) { true }

      it { is_expected.to eq :check_merits_answers }
    end

    context "when chances_of_success is false" do
      let(:success_likely) { false }

      it { is_expected.to eq :check_merits_answers }
    end
  end
end
