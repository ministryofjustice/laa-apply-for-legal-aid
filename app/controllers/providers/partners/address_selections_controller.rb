module Providers
  module Partners
    class AddressSelectionsController < ProviderBaseController
      include AddressHandling
      prefix_step_with :partner

      def show
        return redirect_to back_path unless partner.postcode

        if address_lookup.success?
          @addresses = address_lookup.result
          titleize_addresses
          @address_collection = collect_addresses
          @form = Addresses::PartnerAddressSelectionForm.new(model: partner)
        else
          @form = Addresses::PartnerAddressForm.new(model: partner, lookup_error: address_lookup.errors[:lookup].first)
          render template: "providers/partners/addresses/show".freeze
        end
      end

      def update
        @addresses = build_addresses_from_form_data
        @address_collection = collect_addresses
        @form = Addresses::PartnerAddressSelectionForm.new(permitted_params)
        render :show unless save_continue_or_draft(@form)
      end

    private

      def partner
        legal_aid_application.partner
      end

      def address_lookup
        @address_lookup ||= AddressLookupService.call(partner.postcode)
      end

      def permitted_params
        merge_with_model(partner, addresses: @addresses) do
          params.require(:address_selection).permit(:lookup_id, :postcode)
        end
      end
    end
  end
end
