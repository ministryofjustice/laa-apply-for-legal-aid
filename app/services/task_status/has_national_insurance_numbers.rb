module TaskStatus
  class HasNationalInsuranceNumbers < Base
    def call
      status = ValueObject.new

      status.cannot_start!

      status.not_started! if not_started?
      status.in_progress! if in_progress?
      status.completed! if completed?
      status
    end

  private

    def not_started?
      applicant.present?
    end

    def in_progress?
      !applicant&.has_national_insurance_number.nil?
    end

    def completed?
      has_national_insurance_numbers_validator.valid?
    end

    def has_national_insurance_numbers_validator
      @has_national_insurance_numbers_validator ||= Validators::HasNationalInsuranceNumbers.new(application)
    end
  end
end
