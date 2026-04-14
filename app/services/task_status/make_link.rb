module TaskStatus
  class MakeLink < Base
  private

    def perform(status)
      status.not_started! if not_started?
      status.cannot_start! if cannot_start?
      status.in_progress! if in_progress?
      status.completed! if completed?
    end

    def not_started?
      application.linked_application_completed.nil?
    end

    def cannot_start?
      !previous_tasks_completed?
    end

    def in_progress?
      application.linked_application_completed == false
    end

    def completed?
      application.linked_application_completed?
    end

    def previous_task_status_items
      @previous_task_status_items ||= [
        Applicants,
      ]
    end
  end
end
