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

    def mark_as_ignored!(group, task)
      task_list.mark_as_ignored!(group, task)
      self.serialized_data = task_list.to_yaml
      save!
    end

    def reset_to_not_started!(group, task)
      task_list.reset_to_not_started!(group, task)
      self.serialized_data = task_list.to_yaml
      save!
    end

    def can_proceed?
      application_states = task_list.tasks[:application].map(&:state).flatten
      proceeding_states = task_list.tasks[:proceedings].map { |task| task[1][:tasks].map(&:state) }.flatten
      all_task_states = application_states + proceeding_states
      (all_task_states.uniq - %i[complete ignored]).empty?
    end
  end
end
