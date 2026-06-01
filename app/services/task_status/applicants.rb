module TaskStatus
  class Applicants < Base
    include ::DurationLogger

  private

    def perform(status)
      log_duration("Time to calculate applicants task list status for #{application.id}") do
        status.in_progress!
        status.not_started! unless applicant
        status.completed! if completed?
      end
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
