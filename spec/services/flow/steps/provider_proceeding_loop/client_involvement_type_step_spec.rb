require "rails_helper"

RSpec.describe Flow::Steps::ProviderProceedingLoop::ClientInvolvementTypeStep, type: :request do
  let(:application) { create(:legal_aid_application, :with_proceedings) }
  let(:proceeding) { application.proceedings.first }

  describe "#path" do
    subject { described_class.path.call(application) }

    it { is_expected.to eql providers_legal_aid_application_client_involvement_type_path(application, proceeding) }
  end

  describe "#forward" do
    subject { described_class.forward }

    it { is_expected.to eq :delegated_functions }
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
