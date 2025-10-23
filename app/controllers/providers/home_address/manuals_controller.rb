module Providers
  module HomeAddress
    class ManualsController < AddressManualsBaseController
      prefix_step_with :home_address
      reviewed_by :legal_aid_application, :check_provider_answers

    private

      def build_address
        applicant.addresses&.where(location: "home")&.destroy_all
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

      def location
        "home"
      end
    end
  end
end
