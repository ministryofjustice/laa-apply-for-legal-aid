module LegalFramework
  class MeritsTaskList < ApplicationRecord
    belongs_to :legal_aid_application

    def task_list
      @task_list ||= SerializableMeritsTaskList.new_from_serialized(serialized_data)
    end

    def mark_as_complete!(group, task)
      task_list.mark_as_complete!(group, task)
      self.serialized_data = task_list.to_yaml
      save!
    end

    def can_proceed?
      states = task_list.tasks[:proceedings].map { |task| task[1][:tasks].map(&:state) }.flatten
      states.all?(:complete)
    end
  end
end
