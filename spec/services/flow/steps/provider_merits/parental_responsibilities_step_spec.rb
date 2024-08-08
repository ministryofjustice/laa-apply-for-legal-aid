require "rails_helper"

RSpec.describe Flow::Steps::ProviderMerits::ParentalResponsibilitiesStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }
  let(:proceeding) { create(:proceeding, :pb003, legal_aid_application:) }

  before do
    allow(legal_aid_application).to receive(:provider_step_params).and_return({ "merits_task_list_id" => proceeding.id })
    allow(Flow::MeritsLoop).to receive(:forward_flow).and_return(:merits_task_lists)
  end

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_merits_task_list_does_client_have_parental_responsibility_path(proceeding) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application, options) }

    context "when reshow_check_client is set to true" do
      let(:options) { { reshow_check_client: true } }

      it { is_expected.to eq :check_who_client_is }
    end

    context "when reshow_check_client is set to false" do
      let(:options) { { options: { reshow_check_client: false } } }

      it { is_expected.to eq :merits_task_lists }
    end
  end
end
