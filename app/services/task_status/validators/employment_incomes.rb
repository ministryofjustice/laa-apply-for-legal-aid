module TaskStatus
  module Validators
    class EmploymentIncomes < Base
      def valid?
        forms.each { |form| return true if form.valid? }

        false
      end

    private

      def forms
        [
          full_employment_details_form,
          unexpected_employment_income_form,
          employment_income_form,
        ]
      end

      def full_employment_details_form
        @full_employment_details_form ||= ::LegalAidApplications::FullEmploymentDetailsForm.new(model: application)
      end

      def unexpected_employment_income_form
        @unexpected_employment_income_form ||= ::Applicants::UnexpectedEmploymentIncomeForm.new(model: applicant)
      end

      def employment_income_form
        @employment_income_form ||= ::Applicants::EmploymentIncomeForm.new(model: applicant)
      end
    end
  end
end
