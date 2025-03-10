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
      forms.all?(&:valid?) &&
        validators.all?(&:valid?)
    end

    def forms
      []
    end

    def validators
      [
        proceedings_validator,
      ]
    end

    def proceedings_validator
      @proceedings_validator ||= Validators::Proceedings.new(application)
    end
  end
end
