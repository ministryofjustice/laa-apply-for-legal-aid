# A task status object is responsible for determining what the status
# of a particular task is. It is a Task status analyzer or service class!
#
# There should be a task status subclass for, and named after, each task
# presenter object.
#
# Each task status object should respond to `call` and return a tast status
# value object`
module TaskStatus
  class Base
    attr_accessor :application

    delegate :applicant, :passported?, :non_passported?, :non_means_tested?, to: :application

    def initialize(application, status_results)
      @application = application
      @status_results = status_results
    end

    def call
      status = build_status

      perform(status)
      record(status)

      status
    end

  private

    def build_status
      ValueObject.new
    end

    def record(status)
      @status_results[self.class] = status
    end

    def perform(status)
      raise NotImplementedError, "Subclasses of TaskStatus::Base must implement the perform method"
    end

    def previous_tasks_completed?
      return @previous_tasks_completed if defined?(@previous_tasks_completed)

      @previous_tasks_completed = previous_task_status_items.all? do |task_class|
        @status_results[task_class]&.completed?
      end
    end

    # Override in subclass if there are previous tasks to check, otherwise will return an empty array and previous_tasks_completed? will return true
    def previous_task_status_items
      @previous_task_status_items ||= []
    end
  end
end
