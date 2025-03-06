module Providers
  module HomeAddress
    class NonUkHomeAddressesController < ProviderBaseController
      def show
        @form = Addresses::NonUkHomeAddressForm.new(model: non_uk_home_address)
      end

      def update
        @form = Addresses::NonUkHomeAddressForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

    private

      def build_address
        Address.new(
          applicant:,
          location: "home",
        )
      end

      def non_uk_home_address
        @non_uk_home_address ||= current_non_uk_home_address || build_address
      end

      def current_non_uk_home_address
        return nil unless applicant.home_address && applicant.home_address.country_code != "GBR"

        applicant.home_address
      end

      def form_params
        merge_with_model(non_uk_home_address) do
          params.expect(
            non_uk_home_address: %i[country_name address_line_one address_line_two city county]
          ).merge(postcode: nil)
        end
      end
    end
  end
end
