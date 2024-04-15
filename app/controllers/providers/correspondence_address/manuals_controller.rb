module Providers
  module CorrespondenceAddress
    class ManualsController < AddressManualsBaseController
      prefix_step_with :correspondence_address

    private

      def location
        "correspondence"
      end

      def address
        applicant.address || applicant.build_address(country_code: "GBR", country_name: "United Kingdom")
      end
    end
  end
end
