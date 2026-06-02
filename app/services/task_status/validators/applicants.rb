module TaskStatus
  module Validators
    class Applicants < Base
      def initialize(application, test_progression: false)
        super
      end

    private

      def forms
        if @test_progression
          {
            "client_case_details" => {
              "client_details" => %w[
                Applicants::BasicDetailsForm
                Applicants::HasNationalInsuranceNumberForm
                Applicants::PreviousReferenceForm
              ],
            },
          }
        else
          [
            basic_details_form,
            has_national_insurance_number_form,
            previous_reference_form,
          ]
        end
      end

      # models that have validation or "completion" logic across multiple forms will need careful consideration
      # to ensure we "check" we have all the data to consider them complete. e.g. addresses, linked applications.
      def validators
        [
          address_validator,
        ]
      end

      def basic_details_form
        @basic_details_form ||= ::Applicants::BasicDetailsForm.new(model: applicant)
      end

      def has_national_insurance_number_form
        @has_national_insurance_number_form ||= ::Applicants::HasNationalInsuranceNumberForm.new(model: applicant)
      end

      def previous_reference_form
        @previous_reference_form ||= ::Applicants::PreviousReferenceForm.new(model: applicant)
      end

      def address_validator
        @address_validator ||= Validators::Address.new(applicant)
      end
    end
  end
end
