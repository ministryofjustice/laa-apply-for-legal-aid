# A Task::List is a hash

module Task
  class Base
    def self.build(name, **)
      class_name = "Task::#{name.camelize}"

      if const_defined?(class_name)
        class_name.constantize.new(**)
      else
        new(**)
      end
    end

    attr_accessor :application, :item_statuses

    def initialize(application:, item_statuses: TaskList::ItemStatus.new)
      @application = application
      @item_statuses = item_statuses
    end

    def status
      item_statuses.self_status(task: self)
    end

    def current_status
    end

    def not_applicable?
    end

    def not_startable?
    end

    def in_progress?
    end

    def completed?
      task_forms.map(&:completed?)
    end

    def task_forms
      []
    end
  end
end
