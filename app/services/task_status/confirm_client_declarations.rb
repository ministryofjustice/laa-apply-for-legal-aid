module TaskStatus
  class ConfirmClientDeclarations < Base
    def call
      status = ValueObject.new

      status.cannot_start!
      status.in_progress! if in_progress?
      status.not_started! if not_started?
      status.completed! if completed?

      status
    end

  private

    def not_started?
      false
    end

    def in_progress?
      false
    end

    def completed?
      false
    end
  end
end
