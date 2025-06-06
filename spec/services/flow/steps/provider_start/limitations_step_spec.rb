require "rails_helper"

RSpec.describe Flow::Steps::ProviderStart::LimitationsStep, type: :request do
  before { allow(Flow::ProceedingLoop).to receive(:next_step).and_return(:client_involvement_type) }

  let(:legal_aid_application) { create(:legal_aid_application) }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_limitations_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    context "when overriding the DWP result" do
      before { allow(legal_aid_application).to receive(:overriding_dwp_result?).and_return(true) }

      it { is_expected.to eq :check_provider_answers }
    end

    context "when not overriding the DWP result" do
      it { is_expected.to eq :client_has_partners }
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers }

    it { is_expected.to be :check_provider_answers }
  end
end
