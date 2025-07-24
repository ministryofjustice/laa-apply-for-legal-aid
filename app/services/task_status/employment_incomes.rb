module TaskStatus
  class EmploymentIncomes < Base
    def call
      status = ValueObject.new

      # status.not_ready! if not_ready?
      status.not_started! if not_started?
      status.in_progress! if in_progress?
      status.completed! if completed?

      status
    end

  private

    def not_ready?
      true
      # TODO: application.confirm_dwp_result != true
    end

    def not_started?
      applicant.employed.nil?
    end

    def in_progress?
      applicant.employed && !employment_incomes_validator.valid?
    end

    def completed?
      applicant.employed && employment_incomes_validator.valid?
    end

    def employment_incomes_validator
      @employment_incomes_validator ||= Validators::EmploymentIncomes.new(application)
    end
  end
end
