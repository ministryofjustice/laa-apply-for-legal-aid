# A Task::List is a hash

module Task
  class Base
    include Rails.application.routes.url_helpers

    def self.build(name, **)
      class_name = "Task::#{name.camelize}"

      if const_defined?(class_name)
        class_name.constantize.new(**)
      else
        new(**)
      end
    end

    # attr_accessor :application, :item_statuses
    attr_accessor :application

    def initialize(application:)
      @application = application
    end

    def path
      raise "Implement in subclass"
    end

    # Default for subclasses is to use a "task tastus" object of the same name.
    # You may prefer override in subclasses, particualrly if additional arguments
    # need passing.
    def status
      task_status_klass = "TaskStatus::#{self.class.to_s.demodulize}"

      if self.class.const_defined?(task_status_klass)
        task_status_klass.constantize.new(application).call
      else
        raise "#{task_status_klass} not implemented!"
      end
    end

    # def current_status
    # end

    # def not_applicable?
    # end

    # def not_startable?
    # end

    # def in_progress?
    # end

    # def completed?
    #   task_forms.map(&:completed?)
    # end

    # def task_forms
    #   []
    # end
  end
end
