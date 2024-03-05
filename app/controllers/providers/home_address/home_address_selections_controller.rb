module Providers
  module HomeAddress
    class HomeAddressSelectionsController < ProviderBaseController
      include AddressHandling

      def show
        return redirect_to back_path unless address.postcode

        @addresses = address_lookup.result
        titleize_addresses
        filter_home_addresses if applicant.home_address.building_number_name.present?
        @address_collection = collect_addresses
        @form = Addresses::AddressSelectionForm.new(model: address)
      end

      def update
        @addresses = build_addresses_from_form_data
        @address_collection = collect_addresses
        @form = Addresses::AddressSelectionForm.new(address_selection_form_params)

        render :show unless save_continue_or_draft(@form)
      end

    private

      def address
        applicant.home_address || applicant.build_address
      end

      def address_lookup
        @address_lookup ||= AddressLookupService.call(address.postcode)
      end

      def address_selection_form_params
        merge_with_model(address, addresses: @addresses) do
          params.require(:address_selection).permit(:lookup_id, :postcode).merge(location: "home")
        end
      end

      def filter_home_addresses
        @addresses.select! do |addr|
          [addr.address_line_one, addr.address_line_two].any? do |str|
            str.downcase.include?(applicant.home_address.building_number_name.downcase)
          end
        end
      end
    end
  end
end
