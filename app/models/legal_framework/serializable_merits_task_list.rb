module LegalFramework
  class SerializableMeritsTaskList
    attr_reader :tasks

    SAFE_SERIALIZABLE_CLASSES = [Symbol, SerializableMeritsTaskList, SerializableMeritsTask].freeze

    def initialize(lfa_response)
      @lfa_response = lfa_response
      @tasks = { application: [], proceedings: {} }

      serialize_application_tasks
      serialize_proceeding_types_tasks
    end

    def tasks_for(task_group)
      tasks = @tasks.fetch(task_group, false)  # returns tasks at application level
      tasks ||= @tasks[:proceedings].fetch(task_group, {})[:tasks]  # returns tasks from within nested :proceedings hash
      return tasks if tasks

      raise KeyError, "key not found: #{task_group.inspect}"
    end

    def task(task_group, task_name)
      task = tasks_for(task_group).detect { |t| t.name == task_name }

      return task unless task.nil?

      raise KeyError, "key not found: #{task_name.inspect}"
    end

    def mark_as_complete!(task_group, task_name)
      task(task_group, task_name).mark_as_complete!
      unblock_dependant_tasks(task_name)
    end

    def self.new_from_serialized(yaml_string)
      YAML.safe_load(yaml_string, SAFE_SERIALIZABLE_CLASSES, aliases: true)
    end

    def empty?
      @tasks[:application].empty? && @tasks[:proceedings].empty?
    end

    private

    def unblock_dependant_tasks(blocking_task)
      @tasks[:proceedings].each do |proceeding|
        proceeding[1][:tasks].each do |task|
          dependencies = task.dependencies.map(&:to_sym)
          task(proceeding[0], task.name).remove_dependency(blocking_task) if dependencies.include?(blocking_task)
        end
      end
    end

    def serialize_application_tasks
      @lfa_response[:application][:tasks].each do |task_name, dependencies|
        @tasks[:application] << SerializableMeritsTask.new(task_name, dependencies: dependencies)
      end
    end

    def serialize_proceeding_types_tasks
      @lfa_response[:proceeding_types].each do |proceeding_type_hash|
        ccms_code = proceeding_type_hash[:ccms_code].to_sym
        proceeding_name = ProceedingType.find_by(ccms_code: ccms_code).meaning
        @tasks[:proceedings][ccms_code] = { name: proceeding_name, tasks: [] }
        proceeding_type_hash[:tasks].each do |task_name, dependencies|
          @tasks[:proceedings][ccms_code][:tasks] << SerializableMeritsTask.new(task_name, dependencies: dependencies)
        end
      end
    end
  end
end
