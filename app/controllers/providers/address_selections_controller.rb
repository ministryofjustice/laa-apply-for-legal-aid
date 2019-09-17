module Providers
  class AddressSelectionsController < ProviderBaseController
    def show # rubocop:disable Metrics/AbcSize
      return redirect_to back_path unless address.postcode

      if address_lookup.success?
        @addresses = address_lookup.result
        titleize_addresses
        @form = Addresses::AddressSelectionForm.new(model: address)
      else
        @form = Addresses::AddressForm.new(model: address, lookup_error: address_lookup.errors[:lookup].first)
        render template: 'providers/addresses/show'.freeze
      end
    end

    def update
      @addresses = build_addresses_from_form_data
      @form = Addresses::AddressSelectionForm.new(permitted_params)

      render :show unless save_continue_or_draft(@form)
    end

    private

    def address_lookup
      @address_lookup ||= AddressLookupService.call(address.postcode)
    end

    def address
      applicant.address || applicant.build_address
    end

    def permitted_params
      merge_with_model(address, addresses: @addresses) do
        params.require(:address_selection).permit(:lookup_id, :postcode)
      end
    end

    def address_list_params
      params.require(:address_selection).permit(list: [])[:list]
    end

    def build_addresses_from_form_data
      address_list_params.to_a.map do |address_params|
        Address.from_json(address_params)
      end
    end

    def titleize_addresses
      @addresses.each do |a|
        a[:organisation] = a[:organisation]&.titleize
        a[:address_line_one] = a[:address_line_one]&.titleize
        a[:address_line_two] = a[:address_line_two]&.titleize
        a[:city] = a[:city]&.titleize
      end
    end
  end
end
