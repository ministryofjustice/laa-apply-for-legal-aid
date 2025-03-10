module TaskStatus
  module Validators
    class HasNationalInsuranceNumbers < Base
    private

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
end
