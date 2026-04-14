module TaskStatus
  class Applicants < Base
  private

    def perform(status)
      status.in_progress!
      status.not_started! unless applicant
      status.completed! if completed?
    end

    def completed?
      return @completed if defined?(@completed)

      @completed = applicants_validator.valid?
    end

    def applicants_validator
      @applicants_validator ||= Validators::Applicants.new(application)
    end
  end
end
