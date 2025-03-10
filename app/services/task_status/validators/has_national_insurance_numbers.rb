module TaskStatus
  module Validators
    class HasNationalInsuranceNumbers < Base
      # def initialize(application)
      #   @application = application
      # end

      # def valid?
      #   forms.all?(&:valid?) &&
      #     validators.all?(&:valid?)
      # end

    private

      # attr_reader :application

      # delegate :applicant, to: :application

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
