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

    delegate :applicant, to: :application

    def initialize(application)
      @application = application
    end

    def call
      raise "Implement in subclass"
    end
  end
end
