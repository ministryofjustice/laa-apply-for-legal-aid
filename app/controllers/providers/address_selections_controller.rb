module Providers
  class AddressSelectionsController < ProviderBaseController
    include AddressHandling

    def show
      return redirect_to back_path unless address.postcode

      legal_aid_application.enter_applicant_details! unless no_state_change_required?

      if address_lookup.success?
        @addresses = address_lookup.result
        titleize_addresses
        @address_collection = collect_addresses
        @form = Addresses::AddressSelectionForm.new(model: address)
      else
        @form = Addresses::AddressForm.new(model: address, lookup_error: address_lookup.errors[:lookup].first)
        render template: "providers/addresses/show".freeze
      end
    end

    def update
      @addresses = build_addresses_from_form_data
      @address_collection = collect_addresses
      @form = Addresses::AddressSelectionForm.new(permitted_params)

      render :show unless save_continue_or_draft(@form)
    end

  private

    def no_state_change_required?
      legal_aid_application.entering_applicant_details? || legal_aid_application.checking_applicant_details?
    end

    def address
      applicant.address || applicant.build_address
    end

    def address_lookup
      @address_lookup ||= AddressLookupService.call(address.postcode)
    end

    def permitted_params
      merge_with_model(address, addresses: @addresses) do
        params.require(:address_selection).permit(:lookup_id, :postcode)
      end
    end
  end
end
