module TaskStatus
  class EmploymentIncomes < Base
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
      false
      # TODO: application.confirm_dwp_result != true
    end

    def not_started?
      applicant.employed.nil?
    end

    def in_progress?
      applicant.employed? && application.full_employment_details.nil? && applicant.extra_employment_information.nil?
    end

    def completed?
      application.full_employment_details.present? || !applicant.extra_employment_information.nil?
    end
  end
end
