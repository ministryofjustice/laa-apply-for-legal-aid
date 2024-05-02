require "rails_helper"

RSpec.describe Flow::Steps::ProviderProceedingLoop::EmergencyLevelOfServiceStep, type: :request do
  let(:application) { create(:legal_aid_application, :with_proceedings) }
  let(:proceeding) { application.proceedings.first }
  let(:options) { { changed_to_full_rep: true } }

  before { allow(application).to receive(:provider_step_params).and_return({ "id" => proceeding.id }) }

  describe "#path" do
    subject { described_class.path.call(application) }

    it { is_expected.to eql providers_legal_aid_application_emergency_level_of_service_path(application, proceeding) }
  end

  describe "#forward" do
    subject { described_class.forward.call(application, options) }

    context "when changed_to_full_rep is true" do
      it { is_expected.to eq :final_hearings }
    end

    context "when changed_to_full_rep is false" do
      let(:options) { { changed_to_full_rep: false } }

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
