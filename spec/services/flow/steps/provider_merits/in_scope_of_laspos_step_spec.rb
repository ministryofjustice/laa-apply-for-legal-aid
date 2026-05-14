require "rails_helper"

RSpec.describe Flow::Steps::ProviderMerits::InScopeOfLasposStep, type: :request do
  let(:legal_aid_application) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8, in_scope_of_laspo:) }
  let(:smtl) { create(:legal_framework_merits_task_list, legal_aid_application:) }
  let(:in_scope_of_laspo) { true }

  describe "#path" do
    subject { described_class.path.call(legal_aid_application) }

    it { is_expected.to eq providers_legal_aid_application_in_scope_of_laspo_path(legal_aid_application) }
  end

  describe "#forward" do
    subject(:forward_step) { described_class.forward.call(legal_aid_application) }

    before do
      allow(Flow::MeritsLoop).to receive(:forward_flow).and_return(:merits_task_lists)
      smtl.mark_as_complete!(:application, :laspo)
      allow(LegalFramework::MeritsTasksService).to receive(:call).with(legal_aid_application).and_return(smtl)
    end

    context "when in_scope_of_laspo is true" do
      it { is_expected.to eq :merits_task_lists }
    end

    context "when in_scope_of_laspo is false" do
      let(:in_scope_of_laspo) { false }

      it { is_expected.to eq :out_of_scope_of_laspo_interrupt }

      it "sets the laspo task to not started" do
        expect { forward_step }
          .to change { legal_aid_application.reload.legal_framework_merits_task_list.task_list.task(:application, :laspo).state }
            .from(:complete)
            .to(:not_started)
      end
    end
  end

  describe "#check_answers" do
    subject { described_class.check_answers }

    it { is_expected.to eq :check_merits_answers }
  end
end
