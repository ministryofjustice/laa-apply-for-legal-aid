module LegalFramework
  class SerializableMeritsTaskList
    attr_reader :tasks

    SAFE_SERIALIZABLE_CLASSES = [Symbol, SerializableMeritsTaskList, SerializableMeritsTask].freeze

    def initialize(lfa_response)
      @lfa_response = lfa_response
      @tasks = { application: [] }

      serialize_application_tasks
      serialize_proceeding_types_tasks
    end

    def tasks_for(task_group)
      @tasks.fetch(task_group)
    end

    def task(task_group, task_name)
      task = tasks_for(task_group).detect { |t| t.name == task_name }

      return task unless task.nil?

      raise KeyError, "key not found: #{task_name.inspect}"
    end

    def mark_as_complete!(task_group, task_name)
      task(task_group, task_name).mark_as_complete!
    end

    def self.new_from_serialized(yaml_string)
      YAML.safe_load(yaml_string, SAFE_SERIALIZABLE_CLASSES, aliases: true)
    end

    private

    def serialize_application_tasks
      @lfa_response[:application][:tasks].each do |task_name, dependencies|
        @tasks[:application] << SerializableMeritsTask.new(task_name, dependencies: dependencies)
      end
    end

    def serialize_proceeding_types_tasks
      @lfa_response[:proceeding_types].each do |proceeding_type_hash|
        ccms_code = proceeding_type_hash[:ccms_code].to_sym
        @tasks[ccms_code] = []
        proceeding_type_hash[:tasks].each do |task_name, dependencies|
          @tasks[ccms_code] << SerializableMeritsTask.new(task_name, dependencies: dependencies)
        end
      end
    end
  end
end
