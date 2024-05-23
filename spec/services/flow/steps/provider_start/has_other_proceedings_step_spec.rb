require "rails_helper"

RSpec.describe Flow::Steps::ProviderStart::HasOtherProceedingsStep, type: :request do
  before { allow(Flow::ProceedingLoop).to receive(:next_step).and_return(:client_involvement_type) }

  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:add_another_proceeding) { true }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_has_other_proceedings_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application, add_another_proceeding) }

    context "when the provider selects to add another proceeding" do
      it { is_expected.to eq :proceedings_types }
    end

    context "when the provider selects to not add another proceeding" do
      let(:add_another_proceeding) { false }

      it { is_expected.to eq :client_involvement_type }
    end
  end
end
