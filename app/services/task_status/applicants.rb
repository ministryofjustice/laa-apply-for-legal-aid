module TaskStatus
  class Applicants < Base
    def call
      status = ValueObject.new

      status.in_progress!
      status.not_started! unless applicant
      status.completed! if completed?

      status
    end

  private

    def completed?
      applicants_validator.valid?
    end

    def applicants_validator
      @applicants_validator ||= Validators::Applicants.new(application)
    end
  end
end
