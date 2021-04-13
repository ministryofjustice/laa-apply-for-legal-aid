require 'rails_helper'

module LegalFramework
  RSpec.describe MeritsTaskList, type: :model do
    before { populate_legal_framework }
    let(:application) { create :legal_aid_application }
    let(:merits_task_list) { described_class.create!(legal_aid_application_id: application.id, serialized_data: dummy_serialized_merits_task_list.to_yaml) }

    describe '.create!' do
      it 'adds a new record' do
        expect { merits_task_list }.to change { MeritsTaskList.count }.by(1)
      end
    end

    def dummy_serialized_merits_task_list
      build :legal_framework_merits_task_list
    end
  end
end
