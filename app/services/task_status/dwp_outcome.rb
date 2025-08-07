module TaskStatus
  class DWPOutcome < Base
    def call
      status = ValueObject.new

      status.not_ready! if not_ready?
      status.not_started! if not_started?
      status.in_progress! if in_progress?
      status.completed! if completed?

      status
    end

  private

    def not_ready?
      !check_provider_answers_completed?
    end

    def not_started?
      check_provider_answers_completed? && application.confirm_dwp_result.nil?
    end

    def in_progress?
      check_provider_answers_completed? && application.confirm_dwp_result == false
    end

    def completed?
      application.confirm_dwp_result == true
    end

    def check_provider_answers_completed?
      CheckProviderAnswers.new(application).call.completed?
    end
  end
end
