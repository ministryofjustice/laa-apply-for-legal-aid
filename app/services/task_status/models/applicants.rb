module TaskStatus
  module Models
    class Applicants
      include ActiveModel::Model
      include ActiveModel::Validations

      attr_reader :legal_aid_application

      def initialize(legal_aid_application)
        @legal_aid_application = legal_aid_application
      end

      delegate :applicant, to: :legal_aid_application

      validate :basic_details,
               :national_insurance_number,
               :previous_reference,
               :address_details

    private

      # Consider: while it is possible to share validation logic between
      # forms and pseudo models by using validators this would couple the logic
      # of task list validity to the forms which may not be desirable (for
      # example draft logic?!).
      def basic_details
        errors.add(:first_name, :blank) if applicant.first_name.blank?
        errors.add(:last_name, :blank) if applicant.last_name.blank?
        errors.add(:date_of_birth, :blank) if applicant.date_of_birth.blank?
        errors.add(:changed_last_name, :inclusion) if [true, false].exclude?(applicant.changed_last_name)
        errors.add(:last_name_at_birth, :blank) if applicant.changed_last_name.to_s == "true" && applicant.last_name_at_birth.blank?
      end

      # Consider: sharing logic in NationalInsuranceHandling mixin
      def national_insurance_number
        errors.add(:has_national_insurance_number, :inclusion) if [true, false].exclude?(applicant.has_national_insurance_number)
        errors.add(:national_insurance_number, :blank) if applicant.has_national_insurance_number? && applicant.national_insurance_number.blank?
        errors.add(:national_insurance_number, :not_valid) if invalid_national_insurance_number?
      end

      # TODO: Share REGEX more centrally
      def invalid_national_insurance_number?
        applicant.has_national_insurance_number? &&
          !Applicant::NINO_REGEXP.match?(applicant.national_insurance_number)
      end

      def previous_reference
        errors.add(:applied_previously, :inclusion) if [true, false].exclude?(applicant.applied_previously)
        errors.add(:previous_reference, :blank) if applicant.applied_previously && applicant.previous_reference.blank?
        errors.add(:previous_reference, :not_valid) if invalid_previous_reference?
      end

      # TODO: Share REGEX more centrally
      def invalid_previous_reference?
        applicant.applied_previously &&
          !::Applicants::PreviousReferenceForm::CCMS_REFERENCE_REGEXP.match?(applicant.previous_reference)
      end

      def address_details
        errors.add(:correspondence_address_choice, :inclusion) if %w[home residence office].exclude?(applicant.correspondence_address_choice)
        errors.add(:base, :not_valid) unless address?
      end

      def address?
        applicant.correspondence_address_choice.present? &&
          (correspondence_address? || home_address?) &&
          care_of?
      end

      def correspondence_address?
        applicant.correspondence_address.present? &&
          applicant.correspondence_address.address_line_one.present? &&
          applicant.correspondence_address.city.present? &&
          applicant.correspondence_address.postcode.present?
      end

      def home_address?
        applicant.home_address.present? &&
          applicant.home_address.address_line_one.present? &&
          applicant.home_address.city.present? &&
          applicant.home_address.postcode.present?
      end

      def care_of?
        applicant.correspondence_address_choice.eql?("home") ||
          (all_correspondence_addresses_care_of_details_valid? &&
          no_fixed_residence_valid?)
      end

      # TODO: could we add the errors here to the specific care_of fields instead of just returning true false
      def all_correspondence_addresses_care_of_details_valid?
        applicant.addresses.filter_map { |address|
          next if address.location.eql?("home")

          [
            address.care_of.blank?,
            address.care_of_first_name.blank? && address.care_of == "person",
            address.care_of_last_name.blank? && address.care_of == "person",
            address.care_of_organisation_name.blank? && address.care_of == "organisation",
          ].none?
        }.all?
      end

      def no_fixed_residence_valid?
        [true, false].include?(applicant.no_fixed_residence)
      end
    end
  end
end
