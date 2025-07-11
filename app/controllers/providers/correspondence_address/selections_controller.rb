module Providers
  module CorrespondenceAddress
    class SelectionsController < AddressSelectionsBaseController
      prefix_step_with :correspondence_address
      reviewed_by :legal_aid_application, :check_provider_answers

    private

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
