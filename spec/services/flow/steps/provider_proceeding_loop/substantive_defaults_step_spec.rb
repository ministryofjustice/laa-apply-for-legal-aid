require "rails_helper"

RSpec.describe Flow::Steps::ProviderProceedingLoop::SubstantiveDefaultsStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:proceeding) { create(:proceeding, :da001, legal_aid_application:, accepted_substantive_defaults:) }
  let(:accepted_substantive_defaults) { true }

  before { allow(legal_aid_application).to receive(:provider_step_params).and_return({ "id" => proceeding.id }) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eql providers_legal_aid_application_substantive_default_path(legal_aid_application, proceeding) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    before { allow(Flow::ProceedingLoop).to receive(:next_step).and_return(:limitations) }

    context "when accepted_substantive_defaults is true" do
      it { is_expected.to eq :limitations }
    end

    context "when accepted_substantive_defaults is false" do
      let(:accepted_substantive_defaults) { false }

      it { is_expected.to eq :substantive_level_of_service }
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
