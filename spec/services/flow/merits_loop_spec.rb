require "rails_helper"

RSpec.describe Flow::MeritsLoop do
  subject(:merits_loop) { described_class.new(legal_aid_application, group) }

  let(:legal_aid_application) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8) }
  let(:merits_task_list) { create(:legal_framework_merits_task_list, :da001_as_defendant_and_child_section_8, legal_aid_application:) }

  describe ".forward_flow" do
    subject(:forward_flow) { merits_loop.forward_flow }

    context "when called at application level" do
      let(:group) { "application" }

      context "when some tasks are complete" do
        before { merits_task_list.mark_as_complete!(:application, :latest_incident_details) }

        it "returns the first :not_started task" do
          expect(forward_flow).to eq :start_opponent_task
        end
      end

      context "when all tasks in group are complete" do
        before { merits_task_list.task_list.tasks[:application].each { |t| merits_task_list.mark_as_complete!(:application, t.name) } }

        it { expect(forward_flow).to eq :merits_task_lists }
      end
    end

    context "when called at proceeding level" do
      context "when some tasks are complete" do
        let(:group) { :SE014 }

        before { merits_task_list.mark_as_complete!(:SE014, :chances_of_success) }

        it "returns the first :not_started task" do
          expect(forward_flow).to eq :attempts_to_settle # this ignores :children_proceeding as it is still unable to be started
        end
      end

      context "when all tasks in group are complete" do
        let(:group) { "DA001" }

        before { merits_task_list.task_list.tasks[:proceedings][:DA001][:tasks].each { |t| merits_task_list.mark_as_complete!(:DA001, t.name) } }

        it { expect(forward_flow).to eq :merits_task_lists }
      end
    end
  end
end
