require "rails_helper"

module LegalFramework
  RSpec.describe OpponentTaskUpdateService do
    subject(:call_service) { described_class.call(legal_aid_application) }

    let(:legal_aid_application) { create(:legal_aid_application, :with_multiple_proceedings_inc_section8) }

    context "when the task list predates the switch" do
      let!(:task_list) { create(:legal_framework_merits_task_list, :broken_opponent, legal_aid_application:) }

      it "replaces the tasks with the new version" do
        call_service
        expect(legal_aid_application.legal_framework_merits_task_list.reload.serialized_data).not_to eql task_list.serialized_data
      end

      context "and the opponent_details task is complete" do
        before do
          legal_aid_application.legal_framework_merits_task_list.mark_as_complete!(:application, :opponent_details)
        end

        it "marks the new values as completed too" do
          call_service
          expect(legal_aid_application.legal_framework_merits_task_list.reload).to have_task_in_state(:application, :opponent_name, :complete)
          expect(legal_aid_application.legal_framework_merits_task_list.reload).to have_task_in_state(:application, :opponent_mental_capacity, :complete)
          expect(legal_aid_application.legal_framework_merits_task_list.reload).to have_task_in_state(:application, :domestic_abuse_summary, :complete)
        end
      end
    end

    context "when the task list is in the new style" do
      let!(:task_list) { create(:legal_framework_merits_task_list, legal_aid_application:) }

      it "does nothing" do
        call_service
        expect(legal_aid_application.legal_framework_merits_task_list.reload.serialized_data).to eql task_list.serialized_data
      end
    end
  end
end
