module Providers
  module HomeAddress
    class LookupsController < AddressLookupsBaseController
      prefix_step_with :home_address
      reviewed_by :legal_aid_application, :check_provider_answers

    private

      def build_address
        Address.new(
          applicant:,
          location: "home",
          country_code: "GBR",
          country_name: "United Kingdom",
        )
      end

      def address
        @address ||= current_uk_home_address || build_address
      end

      def current_uk_home_address
        return nil unless applicant.home_address && applicant.home_address.country_code == "GBR"

        applicant.home_address
      end
    end
  end
end
