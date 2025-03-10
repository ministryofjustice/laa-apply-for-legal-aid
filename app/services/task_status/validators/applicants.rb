module TaskStatus
  module Validators
    class Applicants < Base
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
          basic_details_form,
          previous_reference_form,
        ]
      end

      # models that have validation or "completion" logic across multiple forms will need careful consideration
      # to ensure we "check" we have all the data to consider them complete. e.g. addresses, linked applications.
      def validators
        [
          address_validator,
          linked_applications_validator,
        ]
      end

      def basic_details_form
        @basic_details_form ||= ::Applicants::BasicDetailsForm.new(model: applicant)
      end

      def previous_reference_form
        @previous_reference_form ||= ::Applicants::PreviousReferenceForm.new(model: applicant)
      end

      def address_validator
        @address_validator ||= Validators::Address.new(applicant)
      end

      def linked_applications_validator
        @linked_applications_validator ||= Validators::LinkedApplications.new(application)
      end
    end
  end
end
