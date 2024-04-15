module Providers
  module HomeAddress
    class LookupsController < ProviderBaseController
      prefix_step_with :home_address

      def show
        @form = Addresses::AddressLookupForm.new(model: address)
      end

      def update
        @form = Addresses::AddressLookupForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      end

    private

      def build_address
        Address.new(
          applicant:,
          location: "home",
          country_code: "GBR",
          country_name: "United Kingdom",
        )
      end

      def form_params
        merge_with_model(address) do
          params.require(:address_lookup).permit(:postcode, :building_number_name)
        end
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
