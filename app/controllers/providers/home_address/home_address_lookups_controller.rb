module Providers
  module HomeAddress
    class HomeAddressLookupsController < ProviderBaseController
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
        )
      end

      def form_params
        merge_with_model(address) do
          params.require(:address_lookup).permit(:postcode, :building_number_name)
        end
      end

      def address
        @address ||= applicant.home_address || build_address
      end
    end
  end
end