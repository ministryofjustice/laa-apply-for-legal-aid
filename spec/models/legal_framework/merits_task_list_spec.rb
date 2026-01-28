require "rails_helper"

module LegalFramework
  RSpec.describe MeritsTaskList do
    let(:application) { create(:legal_aid_application, :with_proceedings, :with_multiple_proceedings_inc_section8) }
    let(:merits_task_list) { described_class.create!(legal_aid_application_id: application.id, serialized_data: dummy_serialized_merits_task_list.to_yaml) }
    let(:dummy_serialized_merits_task_list) { build(:legal_framework_serializable_merits_task_list) }

    describe ".create!" do
      it "adds a new record" do
        expect { merits_task_list }.to change(described_class, :count).by(1)
      end
    end

    describe "#task_list" do
      it "returns the serialized data" do
        expect(merits_task_list.task_list).to be_an_instance_of(SerializableMeritsTaskList)
      end

      it "is not empty" do
        expect(merits_task_list.task_list).not_to be_empty
      end

      it "has no complete states" do
        expect(merits_task_list.serialized_data).not_to include("state: :complete")
      end
    end

    describe "#mark_as_complete!" do
      subject(:mark_as_complete) { merits_task_list.mark_as_complete!(:application, task_name) }

      let(:task_name) { :latest_incident_details }

      it { is_expected.to be true }

      it "updates the state of the task" do
        mark_as_complete
        expect(merits_task_list).to have_completed_task(:application, :latest_incident_details)
      end

      context "when the completed task updates a sub task" do
        let(:task_name) { :children_application }

        it "updates the task list and dependencies" do
          expect(merits_task_list).to have_task_in_state(:SE014, :children_proceeding, :waiting_for_dependency)
          mark_as_complete
          expect(merits_task_list).to have_completed_task(:application, :children_application)
          expect(merits_task_list).to have_not_started_task(:SE014, :children_proceeding)
        end
      end
    end

    describe "#mark_as_not_started!" do
      subject(:mark_as_not_started) { merits_task_list.mark_as_not_started!(:application, task_name) }

      before { merits_task_list.mark_as_complete!(:application, :latest_incident_details) }

      let(:task_name) { :latest_incident_details }

      it { is_expected.to be true }

      it "updates the state of the task" do
        mark_as_not_started
        expect(merits_task_list).to have_not_started_task(:application, :latest_incident_details)
      end
    end

    describe "#can_proceed?" do
      subject(:can_proceed) { merits_task_list.can_proceed? }

      context "when not all tasks are complete" do
        before do
          merits_task_list.mark_as_complete!(:application, :statement_of_case)
          merits_task_list.mark_as_complete!(:DA001, :chances_of_success)
        end

        it { is_expected.to be false }
      end

      context "when all tasks are complete" do
        before do
          merits_task_list.mark_as_complete!(:application, :latest_incident_details)
          merits_task_list.mark_as_complete!(:application, :opponent_name)
          merits_task_list.mark_as_complete!(:application, :opponent_mental_capacity)
          merits_task_list.mark_as_complete!(:application, :domestic_abuse_summary)
          merits_task_list.mark_as_complete!(:application, :children_application)
          merits_task_list.mark_as_complete!(:application, :statement_of_case)
          merits_task_list.mark_as_complete!(:application, :why_matter_opposed)
          merits_task_list.mark_as_complete!(:application, :laspo)
          merits_task_list.mark_as_complete!(:DA001, :chances_of_success)
          merits_task_list.mark_as_complete!(:SE014, :chances_of_success)
          merits_task_list.mark_as_complete!(:SE014, :children_proceeding)
          merits_task_list.mark_as_complete!(:SE014, :attempts_to_settle)
        end

        it { is_expected.to be true }
      end

      context "when all tasks are complete or ignored" do
        before do
          merits_task_list.mark_as_complete!(:application, :latest_incident_details)
          merits_task_list.mark_as_complete!(:application, :opponent_name)
          merits_task_list.mark_as_complete!(:application, :opponent_mental_capacity)
          merits_task_list.mark_as_complete!(:application, :domestic_abuse_summary)
          merits_task_list.mark_as_complete!(:application, :children_application)
          merits_task_list.mark_as_ignored!(:application, :statement_of_case)
          merits_task_list.mark_as_complete!(:application, :why_matter_opposed)
          merits_task_list.mark_as_ignored!(:application, :laspo)
          merits_task_list.mark_as_complete!(:DA001, :chances_of_success)
          merits_task_list.mark_as_complete!(:SE014, :chances_of_success)
          merits_task_list.mark_as_complete!(:SE014, :children_proceeding)
          merits_task_list.mark_as_complete!(:SE014, :attempts_to_settle)
        end

        it { is_expected.to be true }
      end
    end

    describe "#includes_task?" do
      subject(:includes_task?) { merits_task_list.includes_task?(group, task) }

      context "when group does not exist" do
        let(:group) { :rubbish }
        let(:task) { :latest_incident_details }

        it { is_expected.to be_falsey }
      end

      context "when task does not exist" do
        let(:group) { :application }
        let(:task) { :rubbish }

        it { is_expected.to be_falsey }
      end

      context "when group and task exist" do
        let(:group) { :application }
        let(:task) { :latest_incident_details }

        it { is_expected.to be_truthy }
      end
    end
  end
end
