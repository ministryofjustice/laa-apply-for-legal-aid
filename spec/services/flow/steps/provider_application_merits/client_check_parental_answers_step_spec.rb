require "rails_helper"

RSpec.describe Flow::Steps::ProviderApplicationMerits::ClientCheckParentalAnswersStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  before do
    allow(Flow::MeritsLoop).to receive(:forward_flow).and_return(:merits_task_lists)
  end

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_client_check_parental_answer_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application) }

    it { is_expected.to eq :merits_task_lists }
  end
end
