require "rails_helper"

RSpec.describe Flow::Steps::ProviderApplicationMerits::ChildIsSubjectStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application) }

  before do
    allow(Flow::MeritsLoop).to receive(:forward_flow).and_return(:merits_task_lists)
  end

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_client_is_child_subject_path(legal_aid_application) }
  end

  describe "#forward" do
    subject { described_class.forward.call(legal_aid_application, options) }

    context "when reshow_check_client is set to true" do
      let(:options) { { reshow_check_client: true } }

      it { is_expected.to eq :application_merits_task_client_check_parental_answers }
    end

    context "when reshow_check_client is set to false" do
      let(:options) { { options: { reshow_check_client: false } } }

      it { is_expected.to eq :merits_task_lists }
    end
  end
end
