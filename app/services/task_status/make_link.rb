module TaskStatus
  class MakeLink < Base
    def call
      status = ValueObject.new

      status.not_started! if not_started?
      status.cannot_start! if cannot_start?
      status.in_progress! if in_progress?
      status.completed! if completed?

      status
    end

  private

    def not_started?
      application.linked_application_completed.nil?
    end

    def cannot_start?
      !Applicants.new(application).call.completed?
    end

    def in_progress?
      application.lead_linked_application.present?
    end

    def completed?
      application.linked_application_completed?
    end
  end
end
