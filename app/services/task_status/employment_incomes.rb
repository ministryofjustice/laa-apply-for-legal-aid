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
      !possible_employment_information?
    end

    def in_progress?
      possible_employment_information? && no_employment_details?
    end

    def completed?
      possible_employment_information? && employment_incomes_validator.valid?
    end

    def employment_incomes_validator
      @employment_incomes_validator ||= Validators::EmploymentIncomes.new(application)
    end

    def possible_employment_information?
      applicant.employed || other_employment_status?
    end

    def other_employment_status?
      applicant.employed == false && applicant.self_employed == false && applicant.armed_forces == false
    end

    def no_employment_details?
      application.full_employment_details.nil? && applicant.extra_employment_information.nil? && applicant.extra_employment_information_details.nil?
    end
  end
end
