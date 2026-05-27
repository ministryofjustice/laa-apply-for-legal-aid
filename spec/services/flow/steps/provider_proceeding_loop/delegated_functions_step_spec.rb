require "rails_helper"

RSpec.describe Flow::Steps::ProviderProceedingLoop::DelegatedFunctionsStep, type: :request do
  let(:application) { create(:legal_aid_application, :with_proceedings) }
  let(:proceeding) { application.proceedings.first }

  describe "#path" do
    subject { described_class.path.call(application) }

    it { is_expected.to eql providers_legal_aid_application_delegated_function_path(application, proceeding) }
  end

  describe "#forward" do
    subject { described_class.forward.call(application) }

    before { allow(Flow::ProceedingLoop).to receive(:next_step).and_return(:client_involvement_type) }

    it { is_expected.to eq :client_involvement_type }
  end

  describe "#check_answers" do
    subject { described_class.check_answers.call(application) }

    context "when next step is confirm_delegated_functions_date" do
      before { allow(Flow::ProceedingLoop).to receive(:next_step).and_return(:confirm_delegated_functions_date) }

      it { is_expected.to eq :confirm_delegated_functions_date }
    end

    context "when next step is not confirm_delegated_functions_date" do
      before { allow(Flow::ProceedingLoop).to receive(:next_step).and_return(:substantive_defaults) }

      it { is_expected.to eq :check_provider_answers }
    end
  end

  describe "#carry_on_sub_flow" do
    subject { described_class.carry_on_sub_flow }

    it { is_expected.to be true }
  end
end
