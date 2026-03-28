module TaskStatus
  class Applicants < Base
    def call
      status = ValueObject.new

      status.in_progress!
      status.not_started! unless applicant
      status.completed! if completed?

      # TODO: can these two lines be moved to super class and removed from all subclasses
      @status_results[self.class] = status
      status
    end

  private

    def completed?
      return @completed if defined?(@completed)

      @completed = applicants_validator.valid?
    end

    def applicants_validator
      @applicants_validator ||= Validators::Applicants.new(application)
    end
  end
end
