module TaskStatus
  module Validators
    class Address
      def initialize(applicant)
        @applicant = applicant
      end

      def valid?
        address?
      end

    private

      attr_reader :applicant

      delegate :address, to: :applicant

      def address?
        applicant.correspondence_address_choice.present? &&
          (correspondence_address? || home_address?) &&
          care_of?
      end

      def correspondence_address?
        applicant.address.present? &&
          applicant.address.address_line_one.present? &&
          applicant.address.city.present? &&
          applicant.address.postcode.present?
      end

      def home_address?
        applicant.home_address.present? &&
          applicant.home_address.address_line_one.present? &&
          applicant.home_address.city.present? &&
          applicant.home_address.postcode.present?
      end

      def care_of?
        applicant.correspondence_address_choice.eql?("home") ||
          (correspondence_address_care_of_forms.all?(&:valid?) &&
           home_address_statuses_form.valid?)
      end

      def correspondence_address_care_of_forms
        applicant.addresses.filter_map do |address|
          ::Addresses::CareOfForm.new(model: address) unless address.location.eql?("home")
        end
      end

      def home_address_statuses_form
        ::HomeAddress::StatusForm.new(model: applicant)
      end
    end
  end
end
