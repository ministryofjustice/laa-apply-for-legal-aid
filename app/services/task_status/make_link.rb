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

    def cannot_start?
      # Correct to proceedings complete when available
      !applicants_validator.valid?
    end

    def in_progress?
      application.lead_linked_application.present? && !completed?
    end

    def not_started?
      application.lead_linked_application.blank?
    end

    def completed?
      make_link_validator.valid?
    end

    def make_link_validator
      @make_link_validator ||= Validators::MakeLink.new(application)
    end

    def applicants_validator
      @applicants_validator ||= Validators::Applicants.new(application)
    end
  end
end
