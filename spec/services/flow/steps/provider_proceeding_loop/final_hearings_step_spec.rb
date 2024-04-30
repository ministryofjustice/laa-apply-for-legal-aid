require "rails_helper"

RSpec.describe Flow::Steps::ProviderProceedingLoop::FinalHearingsStep, type: :request do
  let(:application) { create(:legal_aid_application, :with_proceedings) }
  let(:proceeding) { application.proceedings.first }
  let(:options) { { work_type: } }
  let(:work_type) { :substantive }

  before { allow(application).to receive(:provider_step_params).and_return({ "id" => proceeding.id }) }

  describe "#path" do
    subject { described_class.path.call(application, options) }

    it { is_expected.to eql providers_legal_aid_application_final_hearings_path(application, proceeding, work_type) }
  end

  describe "#forward" do
    subject { described_class.forward.call(application, options) }

    context "when work_type is substantive" do
      it { is_expected.to eq :substantive_scope_limitations }
    end

    context "when work_type is emergency" do
      let(:work_type) { :emergency }

      it { is_expected.to eq :emergency_scope_limitations }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers }

    it { is_expected.to eq :check_provider_answers }
  end

  describe "#carry_on_sub_flow" do
    subject { described_class.carry_on_sub_flow }

    it { is_expected.to be true }
  end
end
