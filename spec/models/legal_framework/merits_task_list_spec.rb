require 'rails_helper'

module LegalFramework
  RSpec.describe MeritsTaskList, type: :model do
    before { populate_legal_framework }
    let(:application) { create :legal_aid_application, :with_multiple_proceeding_types_inc_section8 }
    let(:merits_task_list) { described_class.create!(legal_aid_application_id: application.id, serialized_data: dummy_serialized_merits_task_list.to_yaml) }

    describe '.create!' do
      it 'adds a new record' do
        expect { merits_task_list }.to change { MeritsTaskList.count }.by(1)
      end
    end

    describe '.task_list' do
      it 'returns the serialized data' do
        expect(merits_task_list.task_list).to be_an_instance_of(SerializableMeritsTaskList)
      end

      it 'is not empty' do
        expect(merits_task_list.task_list).to_not be_empty
      end

      it 'has no complete states' do
        expect(merits_task_list.serialized_data).to_not include('state: :complete')
      end
    end

    describe '.mark_as_complete' do
      subject(:mark_as_complete) { merits_task_list.mark_as_complete!(:application, :children_application) }

      before { mark_as_complete }

      it { is_expected.to be true }

      it 'updates the task list' do
        # match pattern => key: :value, newline, any amount of spaces, repeat
        expect(merits_task_list.serialized_data).to match(/name: :children_application\n\s+dependencies: \*\d\n\s+state: :complete/)
        expect(merits_task_list.serialized_data).to match(/name: :children_proceeding\n\s+dependencies: \*\d\n\s+state: :not_started/)
      end
    end

    describe '.can_proceed?' do
      subject(:can_proceed) { merits_task_list.can_proceed? }

      context 'when not all tasks are complete' do
        it { is_expected.to be false }
      end

      context 'when all tasks are complete' do
        before do
          merits_task_list.mark_as_complete!(:application, :latest_incident_details)
          merits_task_list.mark_as_complete!(:application, :opponent_details)
          merits_task_list.mark_as_complete!(:application, :children_application)
          merits_task_list.mark_as_complete!(:DA001, :chances_of_success)
          merits_task_list.mark_as_complete!(:SE014, :chances_of_success)
          merits_task_list.mark_as_complete!(:SE014, :children_proceeding)
          merits_task_list.mark_as_complete!(:SE014, :attempts_to_settle)
        end

        it { is_expected.to be true }
      end
    end

    def dummy_serialized_merits_task_list
      build :legal_framework_serializable_merits_task_list
    end
  end
end
