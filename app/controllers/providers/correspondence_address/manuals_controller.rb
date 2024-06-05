module Providers
  module CorrespondenceAddress
    class ManualsController < AddressManualsBaseController
      prefix_step_with :correspondence_address

    private

      def location
        "correspondence"
      end

      def address_attributes
        %i[address_line_one address_line_two address_line_three city county postcode lookup_postcode lookup_error]
      end

      def address
        applicant.address || applicant.build_address(country_code: "GBR", country_name: "United Kingdom")
      end
    end
  end
end
