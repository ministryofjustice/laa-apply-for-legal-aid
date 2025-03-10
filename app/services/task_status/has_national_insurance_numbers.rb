module TaskStatus
  class HasNationalInsuranceNumbers < Base
    def call
      status = ValueObject.new

      applicant.present? ? status.not_started! : status.cannot_start!
      status.in_progress! unless applicant&.has_national_insurance_number.nil?
      status.completed! if completed?
      status
    end

  private

    def completed?
      has_national_insurance_numbers_validator.valid?
    end

    def has_national_insurance_numbers_validator
      @has_national_insurance_numbers_validator ||= Validators::HasNationalInsuranceNumbers.new(application)
    end
  end
end
