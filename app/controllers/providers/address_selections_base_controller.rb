module Providers
  class AddressSelectionsBaseController < ProviderBaseController
    include AddressHandling

    def show
      return redirect_to back_path unless address.postcode

      @addresses = address_lookup.result
      titleize_addresses
      filter_addresses(building_number_name) if building_number_name
      @address_collection = collect_addresses
      @form = Addresses::AddressSelectionForm.new(model: address)
    end

    def update
      if params[:address_selection][:list]
        @addresses = build_addresses_from_form_data
        @address_collection = collect_addresses
        @form = Addresses::AddressSelectionForm.new(address_selection_form_params)
      else
        @form = Addresses::AddressForm.new(address_form_params)
      end

      render :show unless save_continue_or_draft(@form)
    end

  private

    def address_lookup
      @address_lookup ||= AddressLookupService.call(address.postcode)
    end

    def address_selection_form_params
      merge_with_model(address, addresses: @addresses) do
        params.expect(address_selection: [:lookup_id, :postcode]).merge(location:)
      end
    end

    def address_form_params
      merge_with_model(address) do
        params.expect(address_selection: [:address_line_one, :address_line_two, :city, :county, :postcode, :lookup_postcode]).merge(location:)
      end
    end
  end
end
