module Providers
  module HomeAddress
    class SelectionsController < AddressSelectionsBaseController
      prefix_step_with :home_address
      reviewed_by :legal_aid_application, :check_provider_answers

    private

      def address
        applicant.home_address || applicant.build_address(country_code: "GBR", country_name: "United Kingdom")
      end

      def location
        "home"
      end

      def building_number_name
        @building_number_name ||= applicant&.home_address&.building_number_name
      end
    end
  end
end
