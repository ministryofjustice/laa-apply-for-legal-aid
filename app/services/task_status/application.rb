# NOTE: This NOT a TaskStatus that follows the pattern but rather a pseudo-task-status
# since it is a wrapper for all tasks for a given application and is expected to return
# its own kind of "status" indicating an applications "completeness".
#
module TaskStatus
  class Application < Base
    VALUES = [
      INCOMPLETE = :incomplete,
      COMPLETE = :complete,
    ].freeze

    # TODO; must check entirety of application
    def call
      # return COMPLETE if all_tasks.map(status).all?(:completed?)
      # INCOMPLETE
      INCOMPLETE
    end
  end
end
