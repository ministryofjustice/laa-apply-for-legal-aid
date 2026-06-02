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

      @completed = applicants_model.valid?
    end

    def applicants_model
      @applicants_model ||= Models::Applicants.new(application)
    end
  end
end
