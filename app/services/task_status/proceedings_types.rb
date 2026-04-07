module TaskStatus
  class ProceedingsTypes < Base
  private

    def perform(status)
      status.cannot_start!
      status.in_progress! if in_progress?
      status.not_started! if not_started?
      status.completed! if completed?
    end

    def not_started?
      return @not_started if defined?(@not_started)

      @not_started = previous_tasks_completed? && application.proceedings.empty?
    end

    def in_progress?
      return @in_progress if defined?(@in_progress)

      @in_progress = application.proceedings.any?
    end

    def completed?
      return @completed if defined?(@completed)

      @completed = proceedings_types_validator.valid?
    end

    def proceedings_types_validator
      @proceedings_types_validator ||= Validators::ProceedingsTypes.new(application)
    end

    def previous_task_status_items
      @previous_task_status_items ||= [
        Applicants,
        MakeLink,
      ]
    end
  end
end
