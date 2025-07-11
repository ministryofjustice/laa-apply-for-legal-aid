module Providers
  module CorrespondenceAddress
    class LookupsController < AddressLookupsBaseController
      prefix_step_with :correspondence_address
      reviewed_by :legal_aid_application, :check_provider_answers

    private

      def address
        applicant.address || applicant.build_address(location: "correspondence", country_code: "GBR", country_name: "United Kingdom")
      end
    end
  end
end
