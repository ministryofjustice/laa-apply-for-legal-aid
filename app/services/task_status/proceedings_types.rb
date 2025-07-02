module TaskStatus
  class ProceedingsTypes < Base
    def call
      status = ValueObject.new

      status.in_progress!
      status.not_started! if application.proceedings.empty?
      status.completed! if completed?

      status
    end

  private

    def completed?
      proceedings_validator.valid?
    end

    def proceedings_validator
      @proceedings_validator ||= Validators::ProceedingsTypes.new(application)
    end
  end
end
