module TaskStatus
  class ProceedingsTypes < Base
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
      applicants_validator.valid? && application.proceedings.empty?
    end

    def in_progress?
      application.proceedings.any?
    end

    def completed?
      proceedings_types_validator.valid?
    end

    def applicants_validator
      @applicants_validator ||= Validators::Applicants.new(application)
    end

    def proceedings_types_validator
      @proceedings_types_validator ||= Validators::ProceedingsTypes.new(application)
    end
  end
end
