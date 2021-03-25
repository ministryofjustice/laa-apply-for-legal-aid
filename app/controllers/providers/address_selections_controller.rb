module Providers
  class AddressSelectionsController < ProviderBaseController
    include PreDWPCheckVisible

    def show # rubocop:disable Metrics/AbcSize
      return redirect_to back_path unless address.postcode

      legal_aid_application.enter_applicant_details! unless no_state_change_required?

      if address_lookup.success?
        @addresses = address_lookup.result
        titleize_addresses
        @address_collection = collect_addresses
        @form = Addresses::AddressSelectionForm.new(model: address)
      else
        @form = Addresses::AddressForm.new(model: address, lookup_error: address_lookup.errors[:lookup].first)
        render template: 'providers/addresses/show'.freeze
      end
    end

    def update
      @addresses = build_addresses_from_form_data
      @address_collection = collect_addresses
      @form = Addresses::AddressSelectionForm.new(permitted_params)

      render :show unless save_continue_or_draft(@form)
    end

    private

    def collect_addresses
      count = OpenStruct.new(id: nil, address: t('providers.address_selections.show.addresses_found_text', count: @addresses.size))
      [count] + @addresses.collect { |a| OpenStruct.new(id: a.lookup_id, address: a.full_address) }
    end

    def no_state_change_required?
      legal_aid_application.entering_applicant_details? || legal_aid_application.checking_applicant_details?
    end

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

    def hyphen_safe_titleize(sentence)
      sentence.to_s&.split(' ')&.map(&:capitalize)&.join(' ')
    end

    def titleize_addresses
      @addresses.each do |a|
        a[:address_line_one] = hyphen_safe_titleize(a[:address_line_one])
        a[:address_line_two] = hyphen_safe_titleize(a[:address_line_two])
        a[:city] = hyphen_safe_titleize(a[:city])
        a[:county] = hyphen_safe_titleize(a[:county])
      end
    end
  end
end
