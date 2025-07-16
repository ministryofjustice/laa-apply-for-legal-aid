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
      true
      # TODO: update once validator is ready
      # !check_your_answers_validator.valid?
    end

    def not_started?
      application.confirm_dwp_result.nil?
      # TODO: update once CYA validator is ready
      # check_your_answers_validator.valid? && application.confirm_dwp_result.nil?
    end

    def in_progress?
      application.confirm_dwp_result == false
      # TODO: update once CYA validator is ready
      # check_your_answers_validator.valid? && application.confirm_dwp_result == false
    end

    def completed?
      application.confirm_dwp_result == true
    end
  end
end
