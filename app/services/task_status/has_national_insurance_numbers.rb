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

    delegate :applicant, to: :application

    def completed?
      forms.all?(&:valid?) &&
        validators.all?(&:valid?)
    end

    def forms
      [
        has_national_insurance_number_form,
      ]
    end

    def validators
      []
    end

    def has_national_insurance_number_form
      @has_national_insurance_number_form ||= ::Applicants::HasNationalInsuranceNumberForm.new(model: applicant)
    end
  end
end
