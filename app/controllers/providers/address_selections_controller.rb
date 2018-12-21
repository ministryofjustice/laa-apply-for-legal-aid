module Providers
  class AddressSelectionsController < BaseController
    include Providers::ApplicationDependable
    include Providers::Steppable
    include Providers::SaveAsDraftable

    def show # rubocop:disable Metrics/AbcSize
      return redirect_to back_step_url unless address.postcode

      if address_lookup.success?
        @addresses = address_lookup.result
        @form = Addresses::AddressSelectionForm.new(model: address)
      else
        @form = Addresses::AddressForm.new(model: address, lookup_error: address_lookup.errors[:lookup].first)
        render template: 'providers/addresses/show'.freeze
      end
    end

    def update
      @addresses = build_addresses_from_form_data
      @form = Addresses::AddressSelectionForm.new(permitted_params.merge(addresses: @addresses, model: address))

      if @form.save
        continue_or_save_draft
      else
        render :show
      end
    end

    private

    def address_lookup
      @address_lookup ||= AddressLookupService.call(address.postcode)
    end

    def address
      applicant.address || applicant.build_address
    end

    def permitted_params
      params.require(:address_selection).permit(:lookup_id, :postcode)
    end

    def address_list_params
      params.require(:address_selection).permit(list: [])[:list]
    end

    def build_addresses_from_form_data
      address_list_params.to_a.map do |address_params|
        Address.from_json(address_params)
      end
    end
  end
end
