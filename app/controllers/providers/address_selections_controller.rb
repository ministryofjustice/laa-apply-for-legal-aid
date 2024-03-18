module Providers
  class AddressSelectionsController < ProviderBaseController
    include AddressHandling

    def show
      return redirect_to back_path unless address.postcode

      legal_aid_application.enter_applicant_details! unless no_state_change_required?

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

    def no_state_change_required?
      legal_aid_application.entering_applicant_details? || legal_aid_application.checking_applicant_details?
    end

    def address
      applicant.address || applicant.build_address(country: "GBR")
    end

    def address_lookup
      @address_lookup ||= AddressLookupService.call(address.postcode)
    end

    def address_selection_form_params
      merge_with_model(address, addresses: @addresses) do
        params.require(:address_selection).permit(:lookup_id, :postcode).merge(location: "correspondence")
      end
    end

    def address_form_params
      merge_with_model(address) do
        params.require(:address_selection).permit(:address_line_one, :address_line_two, :city, :county, :postcode, :lookup_postcode).merge(location: "correspondence")
      end
    end

    def building_number_name
      @building_number_name ||= applicant&.address&.building_number_name
    end
  end
end
