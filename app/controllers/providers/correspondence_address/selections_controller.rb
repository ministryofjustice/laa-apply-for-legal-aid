module Providers
  module CorrespondenceAddress
    class SelectionsController < AddressSelectionsBaseController
      prefix_step_with :correspondence_address

    private

      def no_state_change_required?
        legal_aid_application.entering_applicant_details? || legal_aid_application.checking_applicant_details?
      end

      def address
        applicant.address || applicant.build_address(country_code: "GBR", country_name: "United Kingdom")
      end

      def location
        "correspondence"
      end

      def building_number_name
        @building_number_name ||= applicant&.address&.building_number_name
      end
    end
  end
end
